SELECT COUNT(*) AS total_shipments
FROM logistics_shipments;

---Write a SQL query to calculate the SLA breach rate, average transit time, average shipping cost, and total shipments for each delivery partner. 
--Rank delivery partners within each logistics zone based on their SLA breach rate, with the lowest breach rate receiving rank 1.

SELECT
    "Logistics_Zone",
    "Delivery_Partner",
    COUNT("Order_ID") AS total_shipments,
    ROUND(AVG("Transit_Time_Hours")::NUMERIC, 2) AS avg_transit_hours,
    ROUND(AVG("Shipping_Cost_INR")::NUMERIC, 2) AS avg_shipping_cost,
    ROUND(AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100, 2) AS sla_breach_rate,
    RANK() OVER (
        PARTITION BY "Logistics_Zone"
        ORDER BY AVG("Is_Delayed_SLA"::INT) ASC
    ) AS partner_rank
FROM logistics_shipments
GROUP BY
    "Logistics_Zone",
    "Delivery_Partner"
ORDER BY
    "Logistics_Zone",
    partner_rank;


---1. Write a SQL query to calculate monthly shipment volume, average delivery time, SLA breach rate, 
--and month-over-month percentage change in SLA breach rate. 
--Return the results separately for each delivery partner.

WITH monthly_performance AS (
    SELECT
        "Delivery_Partner",
        DATE_TRUNC('month', "Dispatch_Timestamp") AS shipment_month,
        COUNT("Order_ID") AS total_shipments,
        ROUND(AVG("Actual_Delivery_Days")::NUMERIC, 2) AS avg_delivery_days,
        ROUND(AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100, 2) AS sla_breach_rate
    FROM logistics_shipments
    GROUP BY
        "Delivery_Partner",
        DATE_TRUNC('month', "Dispatch_Timestamp")
),
monthly_comparison AS (
    SELECT
        *,
        LAG(sla_breach_rate) OVER (
            PARTITION BY "Delivery_Partner"
            ORDER BY shipment_month
        ) AS previous_month_breach_rate
    FROM monthly_performance
)
SELECT
    "Delivery_Partner",
    TO_CHAR(shipment_month, 'YYYY-MM') AS month,
    total_shipments,
    avg_delivery_days,
    sla_breach_rate,
    previous_month_breach_rate,
    ROUND(
        ((sla_breach_rate - previous_month_breach_rate)
        / NULLIF(previous_month_breach_rate, 0)) * 100,
        2
    ) AS mom_breach_rate_change_pct
FROM monthly_comparison
ORDER BY
    "Delivery_Partner",
    shipment_month;


--Write a SQL query to identify the top 10 origin-destination city pairs with the highest shipment volume. For each route,
--calculate average distance, average transit time, SLA breach rate, and average shipping cost. 
--Include only routes with at least 100 shipments.

SELECT
    "Origin_City",
    "Destination_City",
    COUNT("Order_ID") AS total_shipments,
    ROUND(AVG("Distance_km")::NUMERIC, 2) AS avg_distance_km,
    ROUND(AVG("Transit_Time_Hours")::NUMERIC, 2) AS avg_transit_hours,
    ROUND(AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100, 2) AS sla_breach_rate,
    ROUND(AVG("Shipping_Cost_INR")::NUMERIC, 2) AS avg_shipping_cost
FROM logistics_shipments
GROUP BY
    "Origin_City",
    "Destination_City"
HAVING COUNT("Order_ID") >= 100
ORDER BY
    total_shipments DESC
LIMIT 10;


--Write a SQL query to identify delivery partners whose monthly SLA breach rate exceeded their own overall SLA breach rate in at least three different months. 
--Display the partner name, month, monthly breach rate, overall breach rate, and difference between the two rates.

WITH overall_performance AS (
    SELECT
        "Delivery_Partner",
        AVG("Is_Delayed_SLA"::INT) * 100 AS overall_breach_rate
    FROM logistics_shipments
    GROUP BY "Delivery_Partner"
),
monthly_performance AS (
    SELECT
        "Delivery_Partner",
        DATE_TRUNC('month', "Dispatch_Timestamp") AS shipment_month,
        COUNT("Order_ID") AS total_shipments,
        AVG("Is_Delayed_SLA"::INT) * 100 AS monthly_breach_rate
    FROM logistics_shipments
    GROUP BY
        "Delivery_Partner",
        DATE_TRUNC('month', "Dispatch_Timestamp")
),
comparison AS (
    SELECT
        m."Delivery_Partner",
        m.shipment_month,
        m.monthly_breach_rate,
        o.overall_breach_rate,
        m.monthly_breach_rate - o.overall_breach_rate AS rate_difference
    FROM monthly_performance m
    JOIN overall_performance o
        ON m."Delivery_Partner" = o."Delivery_Partner"
    WHERE m.monthly_breach_rate > o.overall_breach_rate
),
qualified_partners AS (
    SELECT
        "Delivery_Partner"
    FROM comparison
    GROUP BY "Delivery_Partner"
    HAVING COUNT(DISTINCT shipment_month) >= 3
)
SELECT
    c."Delivery_Partner",
    TO_CHAR(c.shipment_month, 'YYYY-MM') AS month,
    ROUND(c.monthly_breach_rate::NUMERIC, 2) AS monthly_breach_rate,
    ROUND(c.overall_breach_rate::NUMERIC, 2) AS overall_breach_rate,
    ROUND(c.rate_difference::NUMERIC, 2) AS breach_rate_difference
FROM comparison c
JOIN qualified_partners q
    ON c."Delivery_Partner" = q."Delivery_Partner"
ORDER BY
    c."Delivery_Partner",
    c.shipment_month;


--Write a SQL query to analyse how weather conditions affect delivery performance across logistics zones. 
--Calculate shipment volume, average transit time, SLA breach rate, and percentage contribution to total SLA breaches for each weather-condition and zone combination.

WITH weather_zone_performance AS (
    SELECT
        "Weather_Condition",
        "Logistics_Zone",
        COUNT("Order_ID") AS total_shipments,
        ROUND(AVG("Transit_Time_Hours")::NUMERIC, 2) AS avg_transit_hours,
        ROUND(AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100, 2) AS sla_breach_rate,
        COUNT(*) FILTER (WHERE "Is_Delayed_SLA" = 1) AS total_sla_breaches
    FROM logistics_shipments
    GROUP BY
        "Weather_Condition",
        "Logistics_Zone"
)
SELECT
    "Weather_Condition",
    "Logistics_Zone",
    total_shipments,
    avg_transit_hours,
    sla_breach_rate,
    total_sla_breaches,
    ROUND(
        total_sla_breaches::NUMERIC * 100 /
        NULLIF(SUM(total_sla_breaches) OVER (), 0),
        2
    ) AS breach_contribution_pct
FROM weather_zone_performance
ORDER BY
    breach_contribution_pct DESC,
    sla_breach_rate DESC;


--Write a SQL query to compare delivery performance during festival and non-festival periods for each delivery partner. 
--Calculate shipment volume, average transit time, SLA breach rate, average pickup delay, and percentage change in SLA breach rate between the two periods.

WITH festival_performance AS (
    SELECT
        "Delivery_Partner",
        "Festival_Peak",
        COUNT("Order_ID") AS total_shipments,
        ROUND(AVG("Transit_Time_Hours")::NUMERIC, 2) AS avg_transit_hours,
        ROUND(AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100, 2) AS sla_breach_rate,
        ROUND(AVG("Pickup_Delay_Hours")::NUMERIC, 2) AS avg_pickup_delay
    FROM logistics_shipments
    GROUP BY
        "Delivery_Partner",
        "Festival_Peak"
),
partner_comparison AS (
    SELECT
        "Delivery_Partner",
        SUM(total_shipments) FILTER (WHERE "Festival_Peak" = 1) AS festival_shipments,
        SUM(total_shipments) FILTER (WHERE "Festival_Peak" = 0) AS non_festival_shipments,
        MAX(sla_breach_rate) FILTER (WHERE "Festival_Peak" = 1) AS festival_breach_rate,
        MAX(sla_breach_rate) FILTER (WHERE "Festival_Peak" = 0) AS non_festival_breach_rate
    FROM festival_performance
    GROUP BY "Delivery_Partner"
)
SELECT
    f."Delivery_Partner",
    f."Festival_Peak",
    CASE
        WHEN f."Festival_Peak" = 1 THEN 'Festival'
        ELSE 'Non-Festival'
    END AS period_type,
    f.total_shipments,
    f.avg_transit_hours,
    f.sla_breach_rate,
    f.avg_pickup_delay,
    ROUND(
        ((p.festival_breach_rate - p.non_festival_breach_rate)
        / NULLIF(p.non_festival_breach_rate, 0))::NUMERIC * 100,
        2
    ) AS festival_vs_nonfestival_change_pct
FROM festival_performance f
JOIN partner_comparison p
    ON f."Delivery_Partner" = p."Delivery_Partner"
ORDER BY
    f."Delivery_Partner",
    f."Festival_Peak" DESC;


--Write a SQL query to identify delivery partners that experienced SLA breaches for at least five consecutive shipments based on dispatch timestamp. 
--Display the partner name, consecutive breach sequence, sequence start timestamp, sequence end timestamp, and number of shipments in the sequence.

WITH shipment_sequence AS (
    SELECT
        "Delivery_Partner",
        "Order_ID",
        "Dispatch_Timestamp",
        "Is_Delayed_SLA",
        ROW_NUMBER() OVER (
            PARTITION BY "Delivery_Partner"
            ORDER BY "Dispatch_Timestamp", "Order_ID"
        ) AS shipment_num,
        ROW_NUMBER() OVER (
            PARTITION BY "Delivery_Partner", "Is_Delayed_SLA"
            ORDER BY "Dispatch_Timestamp", "Order_ID"
        ) AS status_num
    FROM logistics_shipments
),
breach_groups AS (
    SELECT
        "Delivery_Partner",
        "Order_ID",
        "Dispatch_Timestamp",
        shipment_num - status_num AS breach_sequence
    FROM shipment_sequence
    WHERE "Is_Delayed_SLA" = 1
),
consecutive_breaches AS (
    SELECT
        "Delivery_Partner",
        breach_sequence,
        MIN("Dispatch_Timestamp") AS sequence_start_timestamp,
        MAX("Dispatch_Timestamp") AS sequence_end_timestamp,
        COUNT(*) AS consecutive_shipments
    FROM breach_groups
    GROUP BY
        "Delivery_Partner",
        breach_sequence
    HAVING COUNT(*) >= 5
)
SELECT
    "Delivery_Partner",
    breach_sequence,
    sequence_start_timestamp,
    sequence_end_timestamp,
    consecutive_shipments
FROM consecutive_breaches
ORDER BY
    "Delivery_Partner",
    sequence_start_timestamp;


--Write a SQL query to identify delivery partners that have a higher average shipping cost per kilometre but a lower SLA breach rate than the overall dataset averages. 
--Calculate cost per kilometre, average transit time, and SLA breach rate for each qualifying partner.

WITH overall_performance AS (
    SELECT
        AVG("Shipping_Cost_INR" / NULLIF("Distance_km", 0)) AS overall_cost_per_km,
        AVG("Is_Delayed_SLA"::INT) AS overall_breach_rate
    FROM logistics_shipments
),
partner_performance AS (
    SELECT
        "Delivery_Partner",
        ROUND(
            AVG("Shipping_Cost_INR" / NULLIF("Distance_km", 0))::NUMERIC,
            2
        ) AS cost_per_km,
        ROUND(AVG("Transit_Time_Hours")::NUMERIC, 2) AS avg_transit_hours,
        ROUND(
            AVG("Is_Delayed_SLA"::INT)::NUMERIC * 100,
            2
        ) AS sla_breach_rate
    FROM logistics_shipments
    GROUP BY "Delivery_Partner"
)
SELECT
    p."Delivery_Partner",
    p.cost_per_km,
    p.avg_transit_hours,
    p.sla_breach_rate,
    ROUND(o.overall_cost_per_km::NUMERIC, 2) AS overall_cost_per_km,
    ROUND(o.overall_breach_rate::NUMERIC * 100, 2) AS overall_breach_rate
FROM partner_performance p
CROSS JOIN overall_performance o
WHERE
    p.cost_per_km > o.overall_cost_per_km
    AND p.sla_breach_rate < o.overall_breach_rate * 100
ORDER BY
    p.sla_breach_rate ASC;

---Write a SQL query to calculate the average, median, 90th percentile, and standard deviation of actual delivery days for each delivery partner and shipment mode. 
--Identify combinations where the 90th percentile delivery time exceeds the promised SLA average for that combination.

WITH delivery_performance AS (
    SELECT
        "Delivery_Partner",
        "Shipment_Mode",
        COUNT("Order_ID") AS total_shipments,
        AVG("Actual_Delivery_Days") AS avg_delivery_days,
        PERCENTILE_CONT(0.50) WITHIN GROUP (
            ORDER BY "Actual_Delivery_Days"
        ) AS median_delivery_days,
        PERCENTILE_CONT(0.90) WITHIN GROUP (
            ORDER BY "Actual_Delivery_Days"
        ) AS p90_delivery_days,
        STDDEV("Actual_Delivery_Days") AS stddev_delivery_days,
        AVG("SLA_Promised_Days") AS avg_promised_sla
    FROM logistics_shipments
    GROUP BY
        "Delivery_Partner",
        "Shipment_Mode"
)
SELECT
    "Delivery_Partner",
    "Shipment_Mode",
    total_shipments,
    ROUND(avg_delivery_days::NUMERIC, 2) AS avg_delivery_days,
    ROUND(median_delivery_days::NUMERIC, 2) AS median_delivery_days,
    ROUND(p90_delivery_days::NUMERIC, 2) AS p90_delivery_days,
    ROUND(stddev_delivery_days::NUMERIC, 2) AS stddev_delivery_days,
    ROUND(avg_promised_sla::NUMERIC, 2) AS avg_promised_sla,
    ROUND(
        (p90_delivery_days - avg_promised_sla)::NUMERIC,
        2
    ) AS p90_vs_promised_difference
FROM delivery_performance
WHERE p90_delivery_days > avg_promised_sla
ORDER BY
    p90_vs_promised_difference DESC;


--Write a SQL query to identify high-risk origin-destination routes for each delivery partner. 
--A route should qualify if its SLA breach rate is greater than the overall SLA breach rate and its average pickup delay is greater than the overall average pickup delay. 
--Rank qualifying routes within each delivery partner based on SLA breach rate and return the top three routes per partner, including shipment volume, average distance, average shipping cost, and SLA breach rate.

WITH overall_performance AS (
    SELECT
        AVG("Is_Delayed_SLA"::INT) AS overall_breach_rate,
        AVG("Pickup_Delay_Hours") AS overall_pickup_delay
    FROM logistics_shipments
),
route_performance AS (
    SELECT
        "Delivery_Partner",
        "Origin_City",
        "Destination_City",
        COUNT("Order_ID") AS total_shipments,
        AVG("Distance_km") AS avg_distance,
        AVG("Shipping_Cost_INR") AS avg_shipping_cost,
        AVG("Pickup_Delay_Hours") AS avg_pickup_delay,
        AVG("Is_Delayed_SLA"::INT) * 100 AS sla_breach_rate
    FROM logistics_shipments
    GROUP BY
        "Delivery_Partner",
        "Origin_City",
        "Destination_City"
),
high_risk_routes AS (
    SELECT
        r.*,
        DENSE_RANK() OVER (
            PARTITION BY r."Delivery_Partner"
            ORDER BY r.sla_breach_rate DESC
        ) AS route_rank
    FROM route_performance r
    CROSS JOIN overall_performance o
    WHERE
        r.sla_breach_rate > o.overall_breach_rate * 100
        AND r.avg_pickup_delay > o.overall_pickup_delay
)
SELECT
    "Delivery_Partner",
    "Origin_City",
    "Destination_City",
    total_shipments,
    ROUND(avg_distance::NUMERIC, 2) AS avg_distance_km,
    ROUND(avg_shipping_cost::NUMERIC, 2) AS avg_shipping_cost,
    ROUND(avg_pickup_delay::NUMERIC, 2) AS avg_pickup_delay_hours,
    ROUND(sla_breach_rate::NUMERIC, 2) AS sla_breach_rate,
    route_rank
FROM high_risk_routes
WHERE route_rank <= 3
ORDER BY
    "Delivery_Partner",
    route_rank;





