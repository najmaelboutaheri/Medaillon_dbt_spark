# Medallion Architecture Pipeline — Azure & dbt

A modern data lakehouse pipeline built on Azure, implementing the **Medallion Architecture** (Bronze → Silver → Gold) to ingest, transform, and serve data from Azure SQL Database for analytics.

---

## Architecture Overview

```
Azure SQL Database
       │
       ▼
Azure Data Factory (ADF)
  └── ForEach pipeline → copies all tables as Parquet files
       │
       ▼
Azure Data Lake Gen2 — Bronze Container
  └── Raw Parquet files (one per table, partitioned by date)
       │
       ▼
Azure Databricks Notebook
  └── Reads Parquet from Bronze → writes Delta tables to Silver
       │
       ▼
Azure Data Lake Gen2 — Silver Container
  └── Delta tables (current state, cleaned)
       │
       ▼
dbt (data build tool)
  ├── Snapshots → tracks historical changes (SCD Type 2)
  └── Models    → aggregations and business logic
       │
       ▼
Azure Data Lake Gen2 — Gold Container
  └── Business-ready tables for dashboards and reporting
```
<img width="765" height="297" alt="image" src="https://github.com/user-attachments/assets/72b881c7-76fb-49f6-a105-625cbcaad310" />

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Azure SQL Database | Source system (transactional data) |
| Azure Data Factory | Data ingestion and pipeline orchestration |
| Azure Data Lake Gen2 | Storage layer (Bronze / Silver / Gold containers) |
| Azure Databricks | Data transformation engine (Apache Spark) |
| Delta Lake | Open table format for reliable data storage |
| dbt (Databricks adapter) | SQL-based transformations and snapshots |
| Azure Key Vault | Secrets management |

---

## Project Structure

```
Medaillon_dbt_spark/
├── models/
│   └── example/              # dbt transformation models (Silver → Gold)
├── snapshots/                # SCD Type 2 snapshot definitions
│   ├── address_snapshot.sql
│   ├── customer_snapshot.sql
│   └── ...                   # one snapshot per source table
├── tests/                    # dbt data quality tests
├── seeds/                    # static reference data (CSV)
├── macros/                   # reusable dbt macros
├── analyses/                 # ad-hoc SQL analyses
├── dbt_project.yml           # dbt project configuration
└── README.md
```

---

## Data Layers

### Bronze — Raw Ingestion
- **Format:** Parquet
- **Content:** Exact copy of source tables from Azure SQL, no transformations
- **Partitioned by:** ingestion date (e.g. `20260424/`)
- **Purpose:** Immutable source of truth — never modified

### Silver — Cleaned & Reliable
- **Format:** Delta
- **Content:** Cleaned, typed, and reliable data promoted from Bronze
- **Purpose:** Single source of truth for all downstream transformations
- **Managed by:** Azure Databricks notebook

### Gold — Business Ready
- **Format:** Delta
- **Content:** Aggregated metrics, joined tables, KPIs
- **Purpose:** Serves dashboards, reports, and analytics
- **Managed by:** dbt models

---

## Source Tables

Data is sourced from the `SalesLT` schema in Azure SQL Database:

- `SalesLT.Address`
- `SalesLT.Customer`
- `SalesLT.CustomerAddress`
- `SalesLT.Product`
- `SalesLT.ProductCategory`
- `SalesLT.ProductDescription`
- `SalesLT.ProductModel`
- `SalesLT.ProductModelProductDescription`
- `SalesLT.SalesOrderDetail`
- `SalesLT.SalesOrderHeader`

---

## Getting Started

### Prerequisites

- Python 3.10+
- Access to Azure Databricks workspace
- Azure Data Lake Gen2 storage account
- Databricks personal access token
- dbt-databricks adapter installed

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd Medaillon_dbt_spark

# Create and activate virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
source venv/bin/activate     # Mac/Linux

# Install dependencies
pip install dbt-databricks
```

### Configure dbt Profile

Create `~/.dbt/profiles.yml`:

```yaml
Medaillon_dbt_spark:
  outputs:
    dev:
      type: databricks
      host: <your-databricks-host>
      http_path: <your-cluster-http-path>
      schema: saleslt
      threads: 1
      token: "{{ env_var('DBT_DATABRICKS_TOKEN') }}"
      managed_location: "wasbs://silver@<storage-account>.blob.core.windows.net/dbt"
  target: dev
```

Set your token as an environment variable:

```bash
export DBT_DATABRICKS_TOKEN="your-databricks-token"   # Mac/Linux
set DBT_DATABRICKS_TOKEN=your-databricks-token        # Windows
```

### Cluster Configuration

In your Databricks cluster's Spark config, add:

```
fs.azure.account.key.<storage-account>.blob.core.windows.net {{secrets/<scope>/<key>}}
```

---

## Running the Pipeline

### 1. Test connection
```bash
dbt debug
```

### 2. Run snapshots (track historical changes)
```bash
dbt snapshot
```

### 3. Run transformation models
```bash
dbt run
```

### 4. Run data quality tests
```bash
dbt test
```

### 5. Generate documentation
```bash
dbt docs generate
dbt docs serve
```

---

## Snapshots (SCD Type 2)

Snapshots track every change to source data over time. Each snapshot adds metadata columns:

| Column | Description |
|---|---|
| `dbt_scd_id` | Unique identifier for each snapshot record |
| `dbt_valid_from` | When this version of the record became active |
| `dbt_valid_to` | When this version was superseded (`null` = current) |
| `dbt_updated_at` | When the record was last updated |

**Strategy:** `check` — detects changes by comparing all columns  
**Hard deletes:** enabled — closes records that disappear from the source

---

## Known Limitations

- DBFS mounts are disabled on this workspace — all storage access uses direct `wasbs://` paths
- Unity Catalog is not configured — Hive Metastore is used with explicit ADLS locations
- Databases must be pre-created in Databricks with explicit LOCATION before running dbt

---

## Author

Najma  
Data Engineer  
