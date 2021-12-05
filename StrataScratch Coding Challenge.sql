-- StrataScratch Coding Challenge

--Workers With The Highest Salaries
--Find the titles of workers that earn the highest salary. Output the highest-paid title or multiple titles that share the highest salary.

SELECT worker_title from worker AS w
LEFT JOIN title AS t
ON w.worker_id = t.worker_ref_id
LEFT JOIN (SELECT MAX(salary) AS max_salary FROM worker) AS max
ON w.salary = max.max_salary
WHERE max_salary IS NOT NULL;

-- Users By Avg Session time
-- Calculate each user's average session time. A session is defined as the time difference between a page_load and page_exit. 
-- For simplicity, assume an user has only 1 session per day and if there are multiple of the same events in that day, consider only the latest page_load and earliest page_exit. 
-- Output the user_id and their average session time.

WITH page_load AS (
SELECT *, DATE(timestamp) AS date,
ROW_NUMBER() OVER (PARTITION BY user_id, DATE(timestamp) ORDER BY timestamp DESC) AS rn
FROM facebook_web_log WHERE action = 'page_load'),
    page_exit AS (
SELECT *, DATE(timestamp) AS date,
ROW_NUMBER() OVER (PARTITION BY user_id, DATE(timestamp) ORDER BY timestamp) AS rn
FROM facebook_web_log WHERE action = 'page_exit'),
 final_table AS (
SELECT l.user_id, l.date AS load_date, l.timestamp AS load_time, e.date AS exit_date, e.timestamp AS exit_time, e.timestamp - l.timestamp AS duration 
FROM (SELECT * FROM page_load WHERE rn=1) AS l
FULL OUTER JOIN (SELECT * FROM page_exit WHERE rn=1) as e
ON l.user_id = e.user_id AND l.date = e.date)

SELECT user_id, AVG(duration) as avg_duration
FROM final_table GROUP BY user_id
HAVING AVG(duration) IS NOT NULL;

-- Acceptance Rate By Date
-- What is the overall friend acceptance rate by date? Your output should have the rate of acceptances by the date the request was sent. Order by the earliest date to latest.
-- Assume that each friend request starts by a user sending (i.e., user_id_sender) a friend request to another user (i.e., user_id_receiver) that's logged in the table with action = 'sent'. 
-- If the request is accepted, the table logs action = 'accepted'. If the request is not accepted, no record of action = 'accepted' is logged.

WITH combine AS (
SELECT s.user_id_sender, s.user_id_receiver, s.date AS send_date, a.date as accepted_date
FROM (SELECT * FROM fb_friend_requests WHERE action = 'sent') AS s
FULL OUTER JOIN (SELECT * FROM fb_friend_requests WHERE action = 'accepted') AS a
ON s.user_id_sender = a.user_id_sender AND s.user_id_receiver = a.user_id_receiver)

SELECT send_date, COUNT(accepted_date)::NUMERIC/COUNT(send_date) as percentage_acceptance
FROM combine
GROUP BY send_date;

-- Highest Energy Consumption
-- Find the date with the highest total energy consumption from the Facebook data centers. 
-- Output the date along with the total energy consumption across all data centers.

WITH combine AS (
SELECT * from fb_eu_energy
UNION
SELECT * from fb_asia_energy
UNION
SELECT * from fb_na_energy),
    agg_combine AS
(SELECT date, SUM(consumption) as total FROM combine GROUP BY date)

SELECT * FROM agg_combine 
WHERE total = (SELECT MAX(total) FROM agg_combine);

-- Finding User Purchases
-- Write a query that'll identify returning active users. 
-- A returning active user is a user that has made a second purchase within 7 days of any other of their purchases. 
-- Output a list of user_ids of these returning active users.

WITH lag_data AS (
SELECT *,
LAG(created_at,1) OVER (PARTITION BY user_id ORDER BY user_id, created_at) AS lag_date
FROM amazon_transactions)

SELECT user_id
FROM lag_data
WHERE created_at - lag_date <=7
GROUP BY user_id
ORDER BY user_id;

-- Customer Revenue In March
-- Calculate the total revenue from each customer in March 2019. 
--Output the revenue along with the customer id and sort the results based on the revenue in descending order.

SELECT cust_id, SUM(total_order_cost) AS total_cost FROM orders
WHERE DATE_TRUNC('month',order_date) = '2019-03-01'
GROUP BY cust_id;

--Classify Business Type
--Classify each business as either a restaurant, cafe, school, or other. 
--A restaurant should have the word 'restaurant' in the business name. 
--For cafes, either 'cafe', 'café', or 'coffee' can be in the business name. 
--'School' should be in the business name for schools. All other businesses should be classified as 'other'. 
--Output the business name and the calculated classification.

SELECT business_name,
CASE WHEN LOWER(business_name) LIKE '%restaurant%' THEN 'restaurant'
     WHEN LOWER(business_name) LIKE '%cafe%' THEN 'cafe'
     WHEN LOWER(business_name) LIKE '%café%' THEN 'cafe'
     WHEN LOWER(business_name) LIKE '%coffee%' THEN 'cafe'
     WHEN LOWER(business_name) LIKE '%school%' THEN 'school' ELSE 'other' 
     END AS business_type
FROM sf_restaurant_health_violations;

--Top Cool Votes
--Find the review_text that received the highest number of  'cool' votes.
--Output the business name along with the review text with the highest numbef of 'cool' votes.
SELECT business_name, review_text FROM yelp_reviews
WHERE cool = (SELECT MAX(cool) FROM yelp_reviews);

--Order Details
--Find order details made by Jill and Eva.
--Consider the Jill and Eva as first names of customers.
--Output the order date, details and cost along with the first name.
--Order records based on the customer id in ascending order.

SELECT order_date, order_details, first_name, SUM(total_order_cost) AS total_cost 
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.cust_id
WHERE first_name IN ('Jill','Eva')
GROUP BY order_date, order_details, c.id, first_name
ORDER BY c.id;

-- Reviews of Categories
-- Find the top business categories based on the total number of reviews. Output the category along with the total number of reviews. 
-- Order by total reviews in descending order.

WITH unnest_cat AS
  (SELECT unnest(string_to_array(categories, ';')) AS category, review_count FROM yelp_business)
SELECT category,
       SUM(review_count) AS review_cnt
FROM unnest_cat
GROUP BY category
ORDER BY review_cnt DESC;

--Highest Salary In Department
--Find the employee with the highest salary per department.
--Output the department name, employee's first name along with the corresponding salary.

WITH high_salary AS (
SELECT department, first_name, salary,
ROW_NUMBER() OVER (PARTITION BY department ORDER BY department, salary DESC) AS rn
FROM employee)

SELECT department, first_name, salary
FROM high_salary
WHERE rn=1;

--Employee and Manager Salaries
--Find employees who are earning more than their managers. Output the employee name along with the corresponding salary.

SELECT e.first_name, e.last_name, e.salary
FROM employee AS e
LEFT JOIN employee AS m
ON e.manager_id = m.id
WHERE e.salary > m.salary;

--Number of violations
--You're given a dataset of health inspections. Count the number of violation in an inspection in 'Roxanne Cafe' for each year. 
--If an inspection resulted in a violation, there will be a value in the 'violation_id' column. 
--Output the number of violations by year in ascending order.

SELECT EXTRACT(YEAR FROM inspection_date) AS year, COUNT(violation_id) FROM sf_restaurant_health_violations
WHERE business_name = 'Roxanne Cafe' AND violation_id IS NOT NULL
GROUP BY year;

