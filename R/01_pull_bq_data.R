# Code to pull data from BigQuery and save as .csv file
# Note: This can only be run by users with access to the BigQuery project and dataset
billing_project <- "emlab-gcp"

# Pull data describing all tanker trips that end in California,
# along with their associated emissions, distance traveled, hours, starting and ending ports, etc
bigrquery::bq_project_query(
  billing_project,
  here::here("sql", "tanker_trip_emissions_ending_in_california.sql") |>
    readr::read_file()
) |>
  bigrquery::bq_table_download(n_max = Inf) |>
  readr::write_csv(here::here(
    "data",
    "tanker_trip_emissions_ending_in_california.csv"
  ))
