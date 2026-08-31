WITH
  -- Pull vessel characteristics for each vessel (id: ssvid); filter to just those that are a tanker class
  vessel_info AS (
    SELECT
      ssvid,
      main_engine_power_kw,
      tonnage_gt,
      length_m,
      flag,
      vessel_class
    FROM `world-fishing-827.proj_ocean_ghg.vessel_info_v20260714`
    WHERE
      vessel_class IN (
        'tanker.oil')
  ),
  -- Get information for each voyage (id: trip), including departure/arrival ports, countries, dates, etc
  -- Only get trips that start in India or Korea, and end in USA
  voyage_info AS (
    SELECT
      *,
      DATE(departure_timestamp) departure_date,
      DATE(arrival_timestamp) arrival_date
    FROM `world-fishing-827.proj_ocean_ghg.voyage_info_v20260714`
    -- WHERE from_country_iso3 IN ('IND', 'KOR') AND to_country_iso3 IN ('USA')
    WHERE from_country_iso3!= 'USA' AND to_country_iso3 = 'USA'
  ),
  -- Get emissions for each voyage (id: ssvid), including distance traveled, hours, and emissions of GHGs and non-GHG pollutants
  voyage_level_emissions AS (
    SELECT
      *
    FROM `world-fishing-827.proj_ocean_ghg.trip_level_emissions_v20260714`
  ),
  -- Get California spatial boundary polygon from  from public data
  -- Polygon includes land and state waters, so will cover all ports in California
  ca_boundary AS (
    SELECT state_geom
    FROM `bigquery-public-data.geo_us_boundaries.states`
    WHERE state_name = 'California'
  ),
  -- Join vessel info, voyage info, and voyage emissions
  -- Also get geography points of starting and ending anchorage
  base AS (
    SELECT
      *,
      -- Convert string to geography and get the start
      ST_STARTPOINT(
        ST_GEOGFROMTEXT(route_string_from_anchorage_to_anchorage_wkt))
        AS start_point,
      -- Convert string to geography and get the end
      ST_ENDPOINT(ST_GEOGFROMTEXT(route_string_from_anchorage_to_anchorage_wkt))
        AS end_point
    FROM
      vessel_info
    JOIN
      voyage_info
      USING (ssvid)
    JOIN
      voyage_level_emissions
      USING (trip_id, ssvid)
  )
-- Now filter to just those trips that end in California
SELECT
  *
  EXCEPT(route_string_from_anchorage_to_anchorage_wkt,state_geom,start_point,end_point,departure_timestamp,arrival_timestamp),
  ST_X(start_point) departure_lon,
  ST_Y(start_point) departure_lat,
  ST_X(end_point) arrival_lon,
  ST_Y(end_point) arrival_lat
FROM
  base
JOIN
  ca_boundary
  ON
    ST_CONTAINS(state_geom, end_point)
