# 🚢 GHG Emissions from California Tankers

Analysis of greenhouse gas (GHG) emissions from ocean tankers arriving at California ports, using an AIS (Automatic Identification System)-based emissions model developed with [Global Fishing Watch (GFW)](https://globalfishingwatch.org/).

[![Render and Publish](https://github.com/emlab-ucsb/ocean-ghg-california-tankers/actions/workflows/publish.yml/badge.svg)](https://github.com/emlab-ucsb/ocean-ghg-california-tankers/actions/workflows/publish.yml)

📊 **[View the Analysis](https://emlab-ucsb.github.io/ocean-ghg-california-tankers/)**

---

## About

This project estimates GHG emissions from tanker vessels arriving at California ports using AIS tracking data and a ship-level emissions model. The model and methodology are described extensively [here](https://emlab-ucsb.github.io/ocean-ghg/).

The analysis queries trip-level emissions data from Global Fishing Watch's BigQuery database for all tanker voyages (chemical/oil, liquefied gas, bunker, and other) departing from non-US ports and arriving at California ports. A SQL query joins vessel characteristics, voyage metadata, and voyage-level emissions, then spatially filters to trips whose arrival point falls within California's boundary.

The primary analytical focus is on **chemical and oil tankers** (`tanker.chemical_oil`) departing from **South Korea and India**. The report includes:

- A summary of trips, vessels, and CO₂ emissions by tanker type
- A breakdown by departure country for all chemical/oil tanker voyages
- A breakdown by departure country and California destination port
- A map of California arrival ports with circles sized by total CO₂ emissions
- Annual time series of trips, vessels, CO₂ emissions, hours at sea, and distance traveled

---

## The dataset

## Column Descriptions

These are the columns in `tanker_trip_emissions_ending_in_california.csv` as output by the SQL query from BigQuery:

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

## 🔄 Reproducing This Analysis

This analysis has two tiers of reproducibility depending on whether you have access to Global Fishing Watch's internal BigQuery database.

---

### Option A — Users without BigQuery Access *(most users)*

You only need the pre-downloaded CSV data file and R/Quarto to render the full analysis.

#### Prerequisites

| Software | Version | Notes |
|----------|---------|-------|
| [R](https://cran.r-project.org/) | ≥ 4.3 | |
| [Positron](https://positron.posit.co/) or [RStudio](https://posit.co/download/rstudio-desktop/) | Latest | Recommended IDE |
| [Quarto](https://quarto.org/docs/get-started/) | ≥ 1.4 | Rendering engine |

R package dependencies are managed with [renv](https://rstudio.github.io/renv/) and recorded in `renv.lock`.

#### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/emlab-ucsb/ocean-ghg-california-tankers.git
   cd ocean-ghg-california-tankers
   ```

2. **Restore R packages** — When you open the project in your IDE, `renv` will automatically bootstrap itself. Then restore packages from the lockfile:

   ```r
   renv::restore()
   ```

3. **Ensure the data are available** — `tanker_trip_emissions_ending_in_california.csv` is available in the `data/` folder. This was pre-downloaded using special permissions to Google BigQuery.

4. **Render the Quarto document**

   ```bash
   quarto render index.qmd
   ```

   Or open `index.qmd` in your IDE and click **Render**.

5. The rendered HTML report will be saved to `docs/index.html`.

---

### Option B — Users with GFW BigQuery Access

If you have been granted access to Global Fishing Watch's BigQuery project, you can re-pull the raw data directly from within the Quarto document.

#### Additional Prerequisites

- A Google Cloud Platform account with access to the Global Fishing Watch BigQuery project

#### Steps

1. **Clone the repository and restore packages** (same as Option A, steps 1–2)

2. **Render with data pulling enabled** — The Quarto document includes a parameterized code chunk that queries BigQuery and saves the result as a CSV. Activate it by passing `pull_data: true`:

   ```bash
   quarto render index.qmd -P pull_data:true
   ```

   This will authenticate via your Google account (browser pop-up), execute the SQL query at `sql/tanker_trip_emissions_ending_in_california.sql`, save the data to `data/tanker_trip_emissions_ending_in_california.csv`, and then continue with the analysis.

---

## 📁 Repository Structure

```
ocean-ghg-california-tankers/
├── _quarto.yml                   # Quarto website project configuration
├── index.qmd                     # Main analysis document (data pull + EDA + visualizations)
├── sql/
│   └── tanker_trip_emissions_ending_in_california.sql  # SQL query for BigQuery
├── data/
│   ├── README.md                 # Data dictionary and column descriptions
│   └── tanker_trip_emissions_ending_in_california.csv  # Downloaded data (not tracked by Git)
├── docs/                         # Rendered HTML output (GitHub Pages source)
├── renv.lock                     # renv lockfile pinning all R package versions
├── .Rprofile                     # Activates renv on project load
├── .github/
│   └── workflows/
│       └── publish.yml           # GitHub Actions: render and deploy to Pages
└── README.md                     # This file
```

---

## How It Works

Everything is contained within the single Quarto document (`index.qmd`):

1. **Data pull** (optional, `params$pull_data = true`) — A parameterized code chunk executes the SQL query at `sql/tanker_trip_emissions_ending_in_california.sql` against BigQuery and saves the result as a CSV. This only runs when explicitly enabled.

2. **Data loading & preparation** — Reads the CSV, adds derived columns (departure country name, flags for countries/vessel classes of interest), and converts the data to an `sf` spatial object using arrival port coordinates.

3. **Analysis & visualization** — Produces summary bar charts, a California port map, time series plots, and a summary table.

---

## 🌐 GitHub Pages

The analysis is automatically rendered and published to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch. The workflow (`.github/workflows/publish.yml`) uses [quarto-dev/quarto-actions](https://github.com/quarto-dev/quarto-actions) to deploy to the `gh-pages` branch.

---

## 📦 Dependencies

R package dependencies are managed with [renv](https://rstudio.github.io/renv/). Run `renv::restore()` to install the exact package versions recorded in `renv.lock`.

Key packages used in the analysis:

| Package | Purpose |
|---------|---------|
| [ggplot2](https://ggplot2.tidyverse.org/) | Plotting |
| [dplyr](https://dplyr.tidyverse.org/) | Data wrangling |
| [tidyr](https://tidyr.tidyverse.org/) | Reshaping data |
| [readr](https://readr.tidyverse.org/) | Reading CSV files |
| [stringr](https://stringr.tidyverse.org/) | String manipulation |
| [lubridate](https://lubridate.tidyverse.org/) | Date/time handling |
| [scales](https://scales.r-lib.org/) | Number formatting |
| [countrycode](https://vincentarelbundock.github.io/countrycode/) | Country code/name conversion |
| [sf](https://r-spatial.github.io/sf/) | Spatial data and mapping |
| [maps](https://cran.r-project.org/web/packages/maps/index.html) | Map data |
| [bigrquery](https://bigrquery.r-dbi.org/) | Google BigQuery interface (data pull only) |
| [here](https://here.r-lib.org/) | Reproducible file paths |
| [knitr](https://yihui.org/knitr/) | Table rendering |

---

## 📬 Contact

This analysis was developed by [emLab at UC Santa Barbara](https://emlab.ucsb.edu).

For questions about data access, please contact Gavin McDonald (gmcdonald@bren.ucsb.edu).
