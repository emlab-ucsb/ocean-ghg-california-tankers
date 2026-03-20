# =============================================================================
# 01_pull_bq_data.R
#
# PURPOSE: Pull tanker voyage and emissions data from Global Fishing Watch
#          BigQuery and save to CSV for offline analysis.
#
# REQUIREMENTS:
#   - Google BigQuery credentials with access to GFW internal datasets
#   - R packages: bigrquery, DBI, tidyverse, here, glue
#
# USAGE:
#   1. Set the configuration variables below (BQ_PROJECT, BQ_DATASET)
#   2. Run: source("R/01_pull_bq_data.R")
#      or execute line-by-line in RStudio
#
# OUTPUT: data/california_tanker_emissions.csv
# =============================================================================

library(bigrquery)
library(DBI)
library(tidyverse)
library(here)
library(glue)

# ─── Configuration ─────────────────────────────────────────────────────────
# Update these to match your GFW BigQuery project and dataset
BQ_PROJECT <- Sys.getenv("GFW_BQ_PROJECT", "your-gfw-bq-project")
BQ_DATASET <- Sys.getenv("GFW_BQ_DATASET", "your-dataset")

# California ports to include
CA_PORTS <- c(
  "Los Angeles",
  "Long Beach",
  "San Francisco",
  "Richmond",
  "Martinez",
  "Benicia",
  "El Segundo",
  "Huntington Beach",
  "Redondo Beach",
  "Carson",
  "Wilmington"
)

# Year range for the query
YEAR_START <- 2016
YEAR_END   <- 2023

# Output file
OUTPUT_FILE <- here("data", "california_tanker_emissions.csv")

# ─── Authenticate ──────────────────────────────────────────────────────────
# Interactive authentication (opens a browser window the first time).
# To use a service account key file instead, set the environment variable:
#   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
# then call bq_auth() without arguments.
bq_auth()

# ─── Connect ───────────────────────────────────────────────────────────────
con <- dbConnect(
  bigrquery::bigquery(),
  project = BQ_PROJECT,
  dataset = BQ_DATASET
)

# ─── Build SQL ─────────────────────────────────────────────────────────────
# Quoted port names for the IN clause
ports_sql <- paste0("'", paste(CA_PORTS, collapse = "','"), "'")

query <- glue("
  WITH california_port_visits AS (
    SELECT
      vessel_id,
      port_label      AS port_name,
      start_timestamp AS arrival_timestamp,
      end_timestamp   AS departure_timestamp,
      anchorage_id
    FROM `{BQ_PROJECT}.{BQ_DATASET}.port_visits`
    WHERE country_iso3 = 'USA'
      AND port_label IN ({ports_sql})
      AND EXTRACT(YEAR FROM start_timestamp) BETWEEN {YEAR_START} AND {YEAR_END}
  ),

  tankers AS (
    SELECT
      vessel_id,
      mmsi,
      vessel_name,
      flag_state,
      vessel_class,
      vessel_length_m,
      vessel_gt
    FROM `{BQ_PROJECT}.{BQ_DATASET}.vessels`
    WHERE vessel_class LIKE '%tanker%'
  )

  SELECT
    t.mmsi,
    t.vessel_name,
    t.flag_state,
    t.vessel_class,
    t.vessel_length_m,
    t.vessel_gt,
    pv.port_name,
    pv.arrival_timestamp,
    pv.departure_timestamp,
    TIMESTAMP_DIFF(pv.departure_timestamp, pv.arrival_timestamp, HOUR) AS port_time_hours,
    e.co2_tonnes,
    e.ch4_tonnes,
    e.n2o_tonnes,
    -- CO2-equivalent using AR5 GWP100 for fossil fuel sources (CH4: 28, N2O: 265)
    (e.co2_tonnes + e.ch4_tonnes * 28 + e.n2o_tonnes * 265) AS co2e_tonnes,
    e.fuel_consumption_tonnes,
    e.voyage_duration_hours,
    e.voyage_distance_nm,
    e.voyage_origin_port,
    e.voyage_origin_country,
    e.engine_type

  FROM california_port_visits pv
  INNER JOIN tankers t
    USING (vessel_id)
  LEFT JOIN `{BQ_PROJECT}.{BQ_DATASET}.voyage_emissions` e
    ON  pv.vessel_id         = e.vessel_id
    AND pv.arrival_timestamp = e.arrival_timestamp

  ORDER BY pv.arrival_timestamp
")

# ─── Execute Query ─────────────────────────────────────────────────────────
message("Executing BigQuery query...")
df <- dbGetQuery(con, query)
message(glue("Query returned {nrow(df)} rows"))

# ─── Save ──────────────────────────────────────────────────────────────────
dir.create(here("data"), showWarnings = FALSE)
write_csv(df, OUTPUT_FILE)
message(glue("Saved to: {OUTPUT_FILE}"))

# ─── Disconnect ────────────────────────────────────────────────────────────
dbDisconnect(con)
message("Done.")
