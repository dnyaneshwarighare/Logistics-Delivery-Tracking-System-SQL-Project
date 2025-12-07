USE logistic; 

SELECT r.rider_id,
       r.name,
       COUNT(*) AS total_deliveries,
       SUM(CASE WHEN d.delivery_status = 'ON_TIME' THEN 1 ELSE 0 END) AS on_time_deliveries,
       ROUND(100.0 * SUM(CASE WHEN d.delivery_status = 'ON_TIME' THEN 1 ELSE 0 END) / COUNT(*), 2)
           AS on_time_rate_pct
FROM Deliveries d
JOIN Riders r ON d.rider_id = r.rider_id
GROUP BY r.rider_id, r.name
ORDER BY on_time_rate_pct DESC;

SELECT c.city,
       c.area,
       AVG(TIMESTAMPDIFF(MINUTE, o.expected_delivery_dt, d.drop_time)) AS avg_delay_min
FROM Orders o
JOIN Deliveries d ON o.order_id = d.order_id
JOIN Customers c ON o.cust_id = c.cust_id
GROUP BY c.city, c.area
ORDER BY avg_delay_min DESC;

SELECT r.rider_id,
       r.name,
       COUNT(*) AS deliveries_count,
       AVG(CASE
               WHEN d.drop_time <= o.expected_delivery_dt
               THEN 1.0
               ELSE 1.0 / (1.0 + TIMESTAMPDIFF(MINUTE, o.expected_delivery_dt, d.drop_time))
           END) AS timeliness_score,
       AVG(r.rating) AS rider_rating,
       (AVG(r.rating) * 0.4 + AVG(CASE
               WHEN d.drop_time <= o.expected_delivery_dt
               THEN 1.0
               ELSE 1.0 / (1.0 + TIMESTAMPDIFF(MINUTE, o.expected_delivery_dt, d.drop_time))
           END) * 0.6) AS performance_score
FROM Deliveries d
JOIN Orders o ON d.order_id = o.order_id
JOIN Riders r ON d.rider_id = r.rider_id
GROUP BY r.rider_id, r.name
ORDER BY performance_score DESC;

SELECT *
FROM Deliveries
WHERE drop_time < pickup_time;

SELECT c.cust_id,
       c.name,
       YEARWEEK(o.order_datetime, 1) AS year_week,
       COUNT(*) AS orders_in_week
FROM Customers c
JOIN Orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.name, year_week
ORDER BY c.cust_id, year_week;