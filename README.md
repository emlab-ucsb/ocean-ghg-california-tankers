# 🚢 GHG Emissions from California Tankers

Analysis of greenhouse gas (GHG) emissions from ocean tankers arriving at California ports, using an AIS (Automatic Identification System)-based emissions model developed with [Global Fishing Watch (GFW)](https://globalfishingwatch.org/).

[![Render and Publish](https://github.com/emlab-ucsb/ocean-ghg-california-tankers/actions/workflows/publish.yml/badge.svg)](https://github.com/emlab-ucsb/ocean-ghg-california-tankers/actions/workflows/publish.yml)

📊 **[View the Analysis](https://emlab-ucsb.github.io/ocean-ghg-california-tankers/)**

---

## About

This project estimates GHG emissions from tanker vessels calling at California ports using AIS tracking data and a ship-level emissions model. Tankers carry crude oil, petroleum products, liquefied natural gas (LNG), chemicals, and other bulk liquids to California's refineries and import terminals.

Emissions estimated include:
- CO₂ (carbon dioxide)
- CH₄ (methane)
- N₂O (nitrous oxide)
- CO₂-equivalent totals (using AR5 GWP100 values)

---

## 🔄 Reproducing This Analysis

This analysis has two tiers of reproducibility depending on whether you have access to Global Fishing Watch's internal BigQuery database.

---

### Option A — Users without BigQuery Access *(most users)*

You only need the pre-downloaded CSV data file and R/Quarto to render the full analysis.

#### Prerequisites

| Software | Version | Notes |
|----------|---------|-------|
| [R](https://cran.r-project.org/) | ≥ 4.3 | |
| [RStudio](https://posit.co/download/rstudio-desktop/) | ≥ 2023.09 | Recommended IDE |
| [Quarto](https://quarto.org/docs/get-started/) | ≥ 1.4 | Rendering engine |

Required R packages are listed in the **Setup** chunk of `index.qmd`. Install them with:

```r
install.packages(c(
  "tidyverse", "bigrquery", "DBI", "here", "glue",
  "gt", "DT", "plotly", "scales", "lubridate",
  "sf", "leaflet", "htmltools", "sessioninfo"
))
```

#### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/emlab-ucsb/ocean-ghg-california-tankers.git
   cd ocean-ghg-california-tankers
   ```

2. **Download the data** — Obtain `california_tanker_emissions.csv` from the project team and place it in the `data/` folder.

3. **Render the Quarto document**

   ```bash
   quarto render index.qmd
   ```

   Or open `index.qmd` in RStudio and click **Render**.

4. The rendered HTML report will open in your browser and is saved to `docs/index.html`.

---

### Option B — Users with GFW BigQuery Access

If you have been granted access to Global Fishing Watch's internal BigQuery dataset, you can re-pull the raw data and regenerate the CSV.

#### Additional Prerequisites

- A Google account with GFW BigQuery permissions
- BigQuery project and dataset names (request from the emLab team)

#### Steps

1. **Clone the repository** (same as Option A, step 1)

2. **Set environment variables** (optional — you can also edit the script directly)

   ```bash
   export GFW_BQ_PROJECT="your-gfw-bq-project"
   export GFW_BQ_DATASET="your-dataset"
   ```

   Or add them to an `.Renviron` file in the project root:

   ```
   GFW_BQ_PROJECT=your-gfw-bq-project
   GFW_BQ_DATASET=your-dataset
   ```

3. **Pull data from BigQuery**

   ```r
   source("R/01_pull_bq_data.R")
   ```

   This will authenticate via your Google account (browser pop-up), execute the SQL query, and save the result to `data/california_tanker_emissions.csv`.

4. **Render the Quarto document** — same as Option A, step 3.

   To re-run the BigQuery queries directly from within the Quarto document, render with:

   ```r
   quarto::quarto_render(
     "index.qmd",
     execute_params = list(pull_data = TRUE,
                           bq_project = "your-gfw-bq-project",
                           bq_dataset = "your-dataset")
   )
   ```

---

## 📁 Repository Structure

```
ocean-ghg-california-tankers/
├── _quarto.yml                   # Quarto website project configuration
├── index.qmd                     # Main analysis document (BigQuery + EDA)
├── R/
│   └── 01_pull_bq_data.R         # Standalone script to pull data from BigQuery
├── data/
│   ├── README.md                 # Data dictionary and column descriptions
│   └── california_tanker_emissions.csv   # Downloaded data (not tracked by Git)
├── docs/                         # Rendered HTML output (GitHub Pages source)
├── .github/
│   └── workflows/
│       └── publish.yml           # GitHub Actions: render and deploy to Pages
└── README.md                     # This file
```

---

## 🌐 GitHub Pages

The analysis is automatically rendered and published to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch. The workflow (`.github/workflows/publish.yml`) uses [quarto-dev/quarto-actions](https://github.com/quarto-dev/quarto-actions) to deploy to the `gh-pages` branch.

> **Note:** The GitHub Actions workflow requires `data/california_tanker_emissions.csv` to be present at render time. Because CSV data files are excluded from Git (see `.gitignore`), you must make the file available to the workflow in one of these ways:
>
> 1. **Temporarily commit the CSV** — add, commit, push the file, trigger the workflow, then revert and push again.
> 2. **GitHub release artifact** — upload the CSV as an asset to a GitHub Release, then add a workflow step to download it (e.g. using `actions/download-artifact` or the GitHub CLI).
> 3. **Encoded secret** — for very small CSVs, base64-encode the file, store it as a repository secret, and decode it in the workflow.
>
> The workflow already includes a safety check that will fail with a clear error message if the CSV is not found, rather than silently producing an empty report.

---

## 📦 Dependencies

This analysis is built with:

| Package | Purpose |
|---------|---------|
| [tidyverse](https://www.tidyverse.org/) | Data wrangling and plotting |
| [bigrquery](https://bigrquery.r-dbi.org/) | Google BigQuery interface |
| [DBI](https://dbi.r-dbi.org/) | Database connectivity |
| [here](https://here.r-lib.org/) | Reproducible file paths |
| [glue](https://glue.tidyverse.org/) | String interpolation for SQL |
| [gt](https://gt.rstudio.com/) | Publication-quality tables |
| [DT](https://rstudio.github.io/DT/) | Interactive data tables |
| [plotly](https://plotly.com/r/) | Interactive plots |
| [scales](https://scales.r-lib.org/) | Number formatting |
| [lubridate](https://lubridate.tidyverse.org/) | Date/time handling |
| [sf](https://r-spatial.github.io/sf/) | Spatial data |
| [leaflet](https://rstudio.github.io/leaflet/) | Interactive maps |
| [sessioninfo](https://sessioninfo.r-lib.org/) | Session reproducibility info |

---

## 📬 Contact

This analysis was developed by [emLab at UC Santa Barbara](https://emlab.ucsb.edu) in collaboration with [Global Fishing Watch](https://globalfishingwatch.org/).

For questions about data access, please contact the emLab team.
