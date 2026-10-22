CREATE DATABASE bengaluru_housing;

USE bengaluru_housing;

SHOW DATABASES;

DESCRIBE house_pricesv2;

USE bengaluru_housing;

CREATE TABLE location_summary AS
SELECT
    location,
    AVG(price_per_sqft) AS avg_price_per_sqft,
    COUNT(*) AS property_count,
    AVG(price) AS avg_price_lakhs
FROM house_pricesv2
WHERE location IS NOT NULL
GROUP BY location;

SELECT *
FROM location_summary
LIMIT 10;

SELECT
    h.location,
    h.price_per_sqft,
    l.avg_price_per_sqft,
    h.price
FROM house_pricesv2 AS h
INNER JOIN location_summary AS l
    ON h.location = l.location
LIMIT 20;

ALTER TABLE house_pricesv2
RENAME COLUMN `ï»¿area_type` TO `area_type`;

# Average price by area type

SELECT
    area_type,
    ROUND(AVG(price), 2) AS avg_price_lakhs,
    COUNT(*) AS property_count
FROM house_pricesv2
GROUP BY area_type
ORDER BY avg_price_lakhs DESC;

#Top 10 locations by average price per sqft

SELECT
    location,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_per_sqft,
    COUNT(*) AS property_count
FROM house_pricesv2
WHERE price_per_sqft IS NOT NULL
GROUP BY location
HAVING COUNT(*) >= 10
ORDER BY avg_price_per_sqft DESC
LIMIT 10;

#Compare property price with its area average — INNER JOIN

SELECT
    h.location,
    h.price AS property_price_lakhs,
    h.price_per_sqft,
    l.avg_price_per_sqft,
    ROUND(h.price_per_sqft - l.avg_price_per_sqft, 2)
        AS difference_from_area_avg
FROM house_pricesv2 h
INNER JOIN location_summary l
    ON h.location = l.location
WHERE h.price_per_sqft IS NOT NULL
LIMIT 20;

#Locations above the overall average — Subquery

SELECT
    location,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_per_sqft
FROM house_pricesv2
WHERE price_per_sqft IS NOT NULL
GROUP BY location
HAVING AVG(price_per_sqft) > (
    SELECT AVG(price_per_sqft)
    FROM house_pricesv2
    WHERE price_per_sqft IS NOT NULL
)
ORDER BY avg_price_per_sqft DESC;

# Rank locations by average price — CTE

WITH location_prices AS (
    SELECT
        location,
        AVG(price_per_sqft) AS avg_price_per_sqft
    FROM house_pricesv2
    WHERE price_per_sqft IS NOT NULL
    GROUP BY location
)
SELECT
    location,
    ROUND(avg_price_per_sqft, 2) AS avg_price_per_sqft
FROM location_prices
ORDER BY avg_price_per_sqft DESC
LIMIT 20;

# Rank properties by price within each location — Window Function

SELECT
    location,
    bhk,
    price,
    RANK() OVER (
        PARTITION BY location
        ORDER BY price DESC
    ) AS price_rank
FROM house_pricesv2
WHERE price IS NOT NULL;

# Compare average prices by BHK

SELECT
    bhk,
    COUNT(*) AS property_count,
    ROUND(AVG(price), 2) AS avg_price_lakhs,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_per_sqft
FROM house_pricesv2
WHERE bhk IS NOT NULL
GROUP BY bhk
ORDER BY bhk;

# Find properties priced above their area's average

SELECT
    h.location,
    h.bhk,
    h.price,
    h.price_per_sqft,
    l.avg_price_per_sqft
FROM house_pricesv2 h
JOIN location_summary l
    ON h.location = l.location
WHERE h.price_per_sqft > l.avg_price_per_sqft
ORDER BY h.price_per_sqft DESC
LIMIT 50;
