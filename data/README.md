# Data Directory

This directory contains downloaded data files used in the analysis.

## Files

| File | Description | Source |
|------|-------------|--------|
| `california_tanker_emissions.csv` | Tanker voyage and emissions data for vessels calling at California ports | Global Fishing Watch BigQuery |

## Column Descriptions

| Column | Type | Description |
|--------|------|-------------|
| `mmsi` | integer | Maritime Mobile Service Identity — unique vessel identifier |
| `vessel_name` | string | Vessel name as broadcast in AIS |
| `flag_state` | string | ISO 3-letter country code for the vessel flag state |
| `vessel_class` | string | Tanker sub-class (e.g. `crude_or_product_tanker`, `chemical_tanker`, `lng_tanker`, `lpg_tanker`) |
| `vessel_length_m` | numeric | Vessel length in metres |
| `vessel_gt` | numeric | Gross tonnage |
| `port_name` | string | California port of arrival |
| `arrival_timestamp` | datetime | UTC timestamp of port arrival |
| `departure_timestamp` | datetime | UTC timestamp of port departure |
| `port_time_hours` | numeric | Time spent in port (hours) |
| `co2_tonnes` | numeric | Voyage CO₂ emissions (metric tonnes) |
| `ch4_tonnes` | numeric | Voyage CH₄ emissions (metric tonnes) |
| `n2o_tonnes` | numeric | Voyage N₂O emissions (metric tonnes) |
| `co2e_tonnes` | numeric | CO₂-equivalent emissions using AR5 GWP100 (CH₄ × 28, N₂O × 265) |
| `fuel_consumption_tonnes` | numeric | Voyage fuel consumption (metric tonnes) |
| `voyage_duration_hours` | numeric | Total voyage duration (hours) |
| `voyage_distance_nm` | numeric | Voyage distance (nautical miles) |
| `voyage_origin_port` | string | Port of departure at the start of the voyage |
| `voyage_origin_country` | string | Country of departure |
| `engine_type` | string | Main engine fuel type (e.g. `HFO`, `VLSFO`, `MGO`, `LNG`) |

## Data Access

Raw data are stored in Global Fishing Watch's internal BigQuery database. To re-download:

1. Ensure you have GFW BigQuery credentials
2. Set environment variables `GFW_BQ_PROJECT` and `GFW_BQ_DATASET`
3. Run `R/01_pull_bq_data.R`

CSV files in this directory are **not tracked by Git** (see `.gitignore`). Download them from the project's [GitHub Releases](../../releases) or request access from the emLab team.
