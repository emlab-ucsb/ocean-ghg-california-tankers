# Data Directory

This directory contains downloaded data files used in the analysis.

## Files

| File | Description | Source |
|------|-------------|--------|
| `tanker_trip_emissions_ending_in_california.csv` | Trip-level emissions data for tanker voyages arriving at California ports | Global Fishing Watch BigQuery (`proj_ocean_ghg` dataset) |

## Column Descriptions

These are the columns in `tanker_trip_emissions_ending_in_california.csv` as output by the SQL query.

| Column | Type | Description |
|--------|------|-------------|
| `trip_id` | string | Unique voyage identifier |
| `ssvid` | string | Source-specific vessel ID (typically MMSI) |
| `main_engine_power_kw` | numeric | Main engine power (kW) |
| `tonnage_gt` | numeric | Gross tonnage |
| `length_m` | numeric | Vessel length (metres) |
| `flag` | string | ISO 3-letter country code for the vessel flag state |
| `vessel_class` | string | Tanker sub-class (e.g., `tanker.chemical_oil`, `tanker.liquefied_gas`, `bunker_or_tanker`, `tanker.other`) |
| `to_anchorage_id` | string | GFW anchorage ID for the arrival port |
| `from_anchorage_id` | string | GFW anchorage ID for the departure port |
| `vessel_id` | string | GFW vessel identifier |
| `from_port` | string | Name of the departure port |
| `from_country_iso3` | string | ISO 3-letter country code of the departure port |
| `to_port` | string | Name of the California arrival port |
| `to_country_iso3` | string | ISO 3-letter country code of the arrival port (always `USA`) |
| `departure_date` | date | Date of departure from origin port |
| `arrival_date` | date | Date of arrival at California port |
| `hours` | numeric | Total voyage duration (hours) |
| `distance_nm` | numeric | Voyage distance (nautical miles) |
| `emissions_co2_mt` | numeric | CO₂ emissions (metric tonnes) |
| `emissions_ch4_mt` | numeric | CH₄ emissions (metric tonnes) |
| `emissions_n2o_mt` | numeric | N₂O emissions (metric tonnes) |
| `emissions_nox_mt` | numeric | NOₓ emissions (metric tonnes) |
| `emissions_sox_mt` | numeric | SOₓ emissions (metric tonnes) |
| `emissions_pm_mt` | numeric | Particulate matter emissions (metric tonnes) |
| `emissions_co_mt` | numeric | CO emissions (metric tonnes) |
| `emissions_vocs_mt` | numeric | Volatile organic compounds emissions (metric tonnes) |
| `emissions_pm2_5_mt` | numeric | PM₂.₅ emissions (metric tonnes) |
| `emissions_pm10_mt` | numeric | PM₁₀ emissions (metric tonnes) |
| `departure_lon` | numeric | Longitude of departure anchorage |
| `departure_lat` | numeric | Latitude of departure anchorage |
| `arrival_lon` | numeric | Longitude of California arrival anchorage |
| `arrival_lat` | numeric | Latitude of California arrival anchorage |