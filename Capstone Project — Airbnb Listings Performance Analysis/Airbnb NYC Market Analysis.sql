CREATE DATABASE IF NOT EXISTS airbnb_db;
USE airbnb_db;

CREATE TABLE airbnb_listings (
  id                              INT,
  listing_name                    VARCHAR(255),
  host_id                         INT,
  host_name                       VARCHAR(100),
  neighbourhood_group             VARCHAR(50),
  neighbourhood                   VARCHAR(100),
  latitude                        DECIMAL(10,6),
  longitude                       DECIMAL(10,6),
  room_type                       VARCHAR(50),
  price                           DECIMAL(10,2),
  minimum_nights                  INT,
  number_of_reviews               INT,
  last_review                     DATE,
  reviews_per_month               DECIMAL(5,2),
  calculated_host_listings_count  INT,
  availability_365                INT
);

LOAD DATA LOCAL INFILE 'C:/mysql_data/AB_NYC.csv'
INTO TABLE airbnb_listings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id,
    listing_name,
    host_id,
    host_name,
    neighbourhood_group,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    price,
    minimum_nights,
    number_of_reviews,
    @last_review,
    reviews_per_month,
    calculated_host_listings_count,
    availability_365
)
SET last_review =
CASE
    WHEN @last_review = '' THEN NULL
    ELSE STR_TO_DATE(@last_review,'%Y-%m-%d')
END;

-- Verify
SELECT COUNT(*) FROM airbnb_listings;
SELECT * FROM airbnb_listings LIMIT 5;


-- Quick sanity check
SELECT
  neighbourhood_group,
  COUNT(*) AS total_listings,
  ROUND(AVG(price),2) AS avg_price
FROM airbnb_listings
GROUP BY neighbourhood_group;

-- Which room type generates the best price and demand?
SELECT
  room_type,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews,
  ROUND(AVG(reviews_per_month), 2)                  AS avg_reviews_per_month,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days,
  ROUND(AVG(365 - availability_365), 0)             AS avg_booked_days_estimate
FROM airbnb_listings
WHERE price > 0
GROUP BY room_type
ORDER BY avg_price DESC;


-- Top 10 highest revenue-generating neighbourhoods

SELECT
  neighbourhood,
  neighbourhood_group                               AS borough,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(365 - availability_365), 0)             AS avg_booked_days,
  ROUND(AVG(price * (365 - availability_365)), 2)   AS avg_estimated_annual_revenue,
  ROUND(SUM(price * (365 - availability_365)), 2)   AS total_estimated_revenue
FROM airbnb_listings
WHERE price > 0 AND availability_365 < 365
GROUP BY neighbourhood, neighbourhood_group
ORDER BY avg_estimated_annual_revenue DESC
LIMIT 10;

--  Does having more reviews correlate with higher price?

SELECT
  CASE
    WHEN number_of_reviews = 0    THEN '1. No Reviews'
    WHEN number_of_reviews <= 10  THEN '2. Low (1-10)'
    WHEN number_of_reviews <= 50  THEN '3. Mid (11-50)'
    WHEN number_of_reviews <= 100 THEN '4. High (51-100)'
    ELSE                              '5. Very High (100+)'
  END                                               AS review_band,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days,
  ROUND(AVG(365 - availability_365), 0)             AS avg_booked_days_estimate
FROM airbnb_listings
WHERE price > 0
GROUP BY review_band
ORDER BY review_band;

-- Professional hosts vs individual hosts

SELECT
  CASE
    WHEN calculated_host_listings_count >= 10
    THEN 'Professional Host (10+ listings)'
    ELSE 'Individual Host (<10 listings)'
  END                                               AS host_type,
  COUNT(*)                                          AS total_listings,
  COUNT(DISTINCT host_id)                           AS unique_hosts,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days,
  ROUND(AVG(price * (365 - availability_365)), 2)   AS avg_estimated_revenue
FROM airbnb_listings
WHERE price > 0
GROUP BY host_type
ORDER BY avg_estimated_revenue DESC;

-- Which price band has the best occupancy (least availability)?

SELECT
  CASE
    WHEN price < 50   THEN '1. Budget (<$50)'
    WHEN price < 150  THEN '2. Mid ($50-150)'
    WHEN price < 300  THEN '3. Premium ($150-300)'
    ELSE                   '4. Luxury ($300+)'
  END                                               AS price_band,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days,
  ROUND(AVG(365 - availability_365), 0)             AS avg_booked_days_estimate,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews,
  ROUND(AVG(price * (365 - availability_365)), 2)   AS avg_estimated_revenue
FROM airbnb_listings
WHERE price > 0
GROUP BY price_band
ORDER BY price_band;


--  Which neighbourhoods are most underserved?

SELECT
  neighbourhood,
  neighbourhood_group                               AS borough,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days
FROM airbnb_listings
WHERE price > 0
GROUP BY neighbourhood, neighbourhood_group
HAVING COUNT(*) < 50
ORDER BY avg_price DESC
LIMIT 15;

--  Minimum nights impact -- does longer minimum stay hurt bookings?

SELECT
  CASE
    WHEN minimum_nights = 1       THEN '1. One Night'
    WHEN minimum_nights <= 3      THEN '2. Short (2-3 nights)'
    WHEN minimum_nights <= 7      THEN '3. Week (4-7 nights)'
    WHEN minimum_nights <= 30     THEN '4. Extended (8-30 nights)'
    ELSE                               '5. Long Term (30+ nights)'
  END                                               AS stay_requirement,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days,
  ROUND(AVG(365 - availability_365), 0)             AS avg_booked_days_estimate
FROM airbnb_listings
WHERE price > 0
GROUP BY stay_requirement
ORDER BY stay_requirement;


-- Top 10 hosts by total estimated portfolio revenue

SELECT
  host_id,
  host_name,
  COUNT(*)                                          AS total_listings,
  ROUND(AVG(price), 2)                              AS avg_listing_price,
  ROUND(SUM(price * (365 - availability_365)), 2)   AS total_estimated_revenue,
  ROUND(AVG(number_of_reviews), 1)                  AS avg_reviews_per_listing,
  GROUP_CONCAT(DISTINCT neighbourhood_group)        AS boroughs_active_in
FROM airbnb_listings
WHERE price > 0 AND availability_365 < 365
GROUP BY host_id, host_name
ORDER BY total_estimated_revenue DESC
LIMIT 10;


-- Year-over-year demand trend using last_review date as proxy

SELECT
  YEAR(last_review)                                 AS review_year,
  COUNT(*)                                          AS listings_with_reviews,
  ROUND(AVG(price), 2)                              AS avg_price,
  ROUND(AVG(reviews_per_month), 2)                  AS avg_reviews_per_month,
  ROUND(AVG(availability_365), 0)                   AS avg_availability_days
FROM airbnb_listings
WHERE last_review IS NOT NULL AND price > 0
GROUP BY YEAR(last_review)
ORDER BY review_year;