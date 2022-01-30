-- StrataScratch Coding Challenge: Medium

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

--Ranking Most Active Guests
--Rank guests based on the number of messages they've exchanged with the hosts. 
--Guests with the same number of messages as other guests should have the same rank. 
--Do not skip rankings if the preceding rankings are identical.
--Output the rank, guest id, and number of total messages they've sent. Order by the highest number of total messages first.

WITH sum_airbnbs AS (
select id_guest, SUM(n_messages) AS sum_messages from airbnb_contacts
GROUP BY id_guest
ORDER BY sum_messages DESC)

SELECT DENSE_RANK() OVER (ORDER BY sum_messages DESC) AS ranking, * FROM sum_airbnbs;

--Number Of Units Per Nationality
--Find the number of apartments per nationality that are owned by people under 30 years old.
--Output the nationality along with the number of apartments.
--Sort records by the apartments count in descending order.

SELECT h.nationality, COUNT(u.unit_id) AS unit_count 
FROM airbnb_units AS u
INNER JOIN airbnb_hosts AS h
ON u.host_id = h.host_id
WHERE h.age < 30 AND unit_type='Apartment'
GROUP BY h.nationality
ORDER BY unit_count DESC;

--Find the rate of processed tickets for each type

SELECT type, SUM(processed_flag)::NUMERIC/COUNT(DISTINCT complaint_id) as rate_processed
FROM (
SELECT *, CASE WHEN processed=TRUE THEN 1 WHEN processed=FALSE THEN 0 END AS processed_flag
FROM facebook_complaints) AS subquery
GROUP BY type;

--Highest Target Under Manager
--Find the highest target achieved by the employee or employees who works under the manager id 13. 
--Output the first name of the employee and target achieved. 
--The solution should show the highest target achieved under manager_id=13 and which employee(s) achieved it.

SELECT first_name, target FROM salesforce_employees
WHERE manager_id=13 AND 
target = (SELECT max(target) FROM salesforce_employees WHERE manager_id=13)
GROUP by first_name, target;

--Income By Title and Gender
---Find the average total compensation based on employee titles and gender. 
---Total compensation is calculated by adding both the salary and bonus of each employee. 
--However, not every employee receives a bonus so disregard employees without bonuses in your calculation. 
--Output the employee title, gender (i.e., sex), along with the average total compensation.

WITH employee_bonus AS (
SELECT employee_title, sex, bonus, salary, bonus+salary AS compensation FROM sf_employee AS e
LEFT JOIN 
(SELECT worker_ref_id, SUM(bonus) AS bonus
FROM sf_bonus
GROUP BY worker_ref_id) AS b
ON e.id = b.worker_ref_id
WHERE bonus>0
ORDER BY employee_title, sex
)

SELECT employee_title,sex,AVG(compensation) AS compensation
FROM employee_bonus
GROUP BY employee_title,sex;

--Find matching hosts and guests in a way that they are both of the same gender and nationality
--Find matching hosts and guests pairs in a way that they are both of the same gender and nationality.
--Output the host id and the guest id of matched pair.

SELECT host_id, guest_id FROM airbnb_hosts AS h
JOIN airbnb_guests AS g
ON h.nationality = g.nationality AND h.gender = g.gender;

--Count the number of user events performed by MacBookPro users
--Count the number of user events performed by MacBookPro users.
--Output the result along with the event name.
--Sort the result based on the event count in the descending order.

SELECT event_name, COUNT(event_name) FROM playbook_events
WHERE device='macbook pro'
GROUP BY event_name;

--Top Ranked Songs
--Find songs that have ranked in the top position. Output the track name and the number of times it ranked at the top. 
--Sort your records by the number of times the song was in the top position in descending order.

SELECT trackname, COUNT(trackname) AS times_top1
FROM spotify_worldwide_daily_song_ranking
WHERE position=1
GROUP BY trackname
ORDER BY COUNT(trackname) DESC;

--Find the total number of available beds per hosts' nationality
--Find the total number of available beds per hosts' nationality.
--Output the nationality along with the corresponding total number of available beds.
--Sort records by the total available beds in descending order.

SELECT nationality, SUM(n_beds) AS available_beds
FROM airbnb_apartments AS apartments
LEFT JOIN airbnb_hosts AS hosts
ON apartments.host_id = hosts.host_id
GROUP BY nationality
ORDER BY SUM(n_beds) DESC;

--Ranking Hosts By Beds
---Rank each host based on the number of beds they have listed. 
--The host with the most beds should be ranked 1 and the host with the least number of beds should be ranked last. 
--Hosts that have the same number of beds should have the same rank. A host can also own multiple properties. 
--Output the host ID, number of beds, and rank from highest rank to lowest.

SELECT host_id, SUM(n_beds), DENSE_RANK() OVER (ORDER BY SUM(n_beds) DESC)
FROM airbnb_apartments
GROUP BY host_id;

--Rank guests based on their ages
--Rank guests based on their ages.
--Output the guest id along with the corresponding rank.
--Order records by the age in descending order.

SELECT guest_id, RANK() OVER (ORDER BY age DESC)
FROM airbnb_guests
GROUP BY guest_id, age;

--Apple Product Counts
--Find the number of Apple product users and the number of total users with a device for each language. 
--Assume Apple products are only MacBook-Pro, iPhone 5s, and iPad-air.  Output the language along with the total number of Apple users and users with any device. 
--Order your results based on the number of total users in descending order.

SELECT language,
COUNT(CASE WHEN device IN ('macbook pro', 'iphone 5s', 'ipad air') THEN events.user_id ELSE NULL END) AS apple_count, COUNT(events.user_id) AS total_count
FROM playbook_events AS events
INNER JOIN playbook_users AS users
ON events.user_id = users.user_id
GROUP BY language
ORDER BY COUNT(events.user_id) DESC;

----------------------------------------------------------------------------------

--MacBook Pro Events
--Find how many events happened on MacBook-Pro per company in Argentina from users that do not speak Spanish.
--Output the company id, language of users, and the number of events performed by users.

SELECT company_id, language, COUNT(event_name) AS event_count
FROM playbook_events AS events
INNER JOIN playbook_users AS users
ON events.user_id = users.user_id
WHERE device='macbook pro' and location='Argentina' and NOT language = 'spanish'
GROUP BY company_id, language;

--Number of Speakers By Language
--Find the number of speakers of each language by country. Output the country, language, and the corresponding number of speakers. 
--Output the result based on the country in ascending order.

SELECT location, language, COUNT(DISTINCT events.user_id) as count_speakers
FROM playbook_events AS events
INNER JOIN playbook_users AS users
ON events.user_id = users.user_id
GROUP BY location, language
ORDER BY location;

--Requests Acceptance Rate
--Find the acceptance rate of requests which is defined as the ratio of accepted contacts vs all contacts. 
--Multiply the ratio by 100 to get the rate.

SELECT ROUND(COUNT(ts_accepted_at)::NUMERIC/ COUNT(id_guest)*100,1) AS acceptance_rate
FROM airbnb_contacts;

--Bookings vs Non-Bookings
--Display the average number of times a user performed a search which led to a successful booking and the average number of times a user performed a search but did not lead to a booking. 
--The output should have a column named action with values 'does not book' and 'books' as well as a 2nd column named average_searches with the average number of searches per action. 
--Consider that the booking did not happen if the booking date is null.