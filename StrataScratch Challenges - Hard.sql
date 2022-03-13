-- StrataScratch Coding Challenge: Hard

--ID: 10319: Monthly Percentage Difference
--Given a table of purchases by date, calculate the month-over-month percentage change in revenue. 
--The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.
--The percentage change column will be populated from the 2nd month forward and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue)*100.

WITH month_revenue AS (
SELECT DATE(DATE_TRUNC('month',created_at)) AS year_month, SUM(value) AS revenue
FROM sf_transactions
GROUP BY year_month),
month_revenue_lag AS (
SELECT *, LAG(revenue,1) OVER (ORDER BY year_month) AS lag_revenue FROM month_revenue)

SELECT TO_CHAR(year_month,'YYYY-MM') AS year_month, ROUND((revenue-lag_revenue)/lag_revenue*100,2) AS revenue_diff_pct
FROM month_revenue_lag
ORDER BY year_month ASC;

--ID:10300: Premium vs Freemium
--Find the total number of downloads for paying and non-paying users by date. 
--Include only records where non-paying customers have more downloads than paying customers. 
--The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.

WITH reference AS (
SELECT user_id, paying_customer FROM ms_user_dimension AS u LEFT JOIN ms_acc_dimension AS a
ON u.acc_id = a.acc_id),
customer AS (
SELECT date, f.user_id, SUM(downloads) AS downloads, paying_customer FROM ms_download_facts AS f 
LEFT JOIN reference AS r
ON f.user_id = r.user_id
GROUP BY date, f.user_id, paying_customer
ORDER BY date),
customer_group AS (
SELECT *, 
CASE WHEN paying_customer = 'yes' THEN downloads END AS paying,
CASE WHEN paying_customer = 'no' THEN downloads END AS non_paying
FROM customer
ORDER BY date),
customer_grouping AS (
SELECT date, SUM(non_paying) AS non_paying, SUM(paying) AS paying
FROM customer_group
GROUP BY date
ORDER BY date)

SELECT * FROM customer_grouping 
WHERE non_paying > paying
ORDER BY date;

--ID:10284: Popularity Percentage
--Find the popularity percentage for each user on Facebook. 
--The popularity percentage is defined as the total number of friends the user has divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
--Output each user along with their popularity percentage. Order records in ascending order by user id.
--The 'user1' and 'user2' column are pairs of friends.

WITH combine AS (
(SELECT user1 AS id1, user2 AS id2 FROM facebook_friends)
UNION
(SELECT user2 AS id1, user1 AS id2 FROM facebook_friends)
ORDER BY id1, id2)

SELECT id1 as user1, ROUND(COUNT(DISTINCT id2)::NUMERIC/(SELECT COUNT(DISTINCT id1) FROM combine)*100,3) AS popularity_percent
FROM combine
GROUP BY id1
ORDER BY id1;

--ID:10046: Top 5 States With 5 Star Businesses
--Find the top 5 states with the most 5 star businesses. 
--Output the state name along with the number of 5-star businesses and order records by the number of 5-star businesses in descending order. 
--In case there are ties in the number of businesses, return all the unique states. 
--If two states have the same result, sort them in alphabetical order.

SELECT state, n_businesses FROM (
SELECT state, COUNT(DISTINCT business_id) AS n_businesses, RANK() OVER (ORDER BY COUNT(DISTINCT business_id) DESC) AS rnk
FROM yelp_business
WHERE stars=5 
GROUP BY state
ORDER BY n_businesses DESC, state ASC) AS subquery
WHERE rnk <=5;

--ID:9915: Highest Cost Orders
--Find the customer with the highest total order cost between 2019-02-01 to 2019-05-01. 
--If customer had more than one order on a certain day, sum the order costs on daily basis. 
--Output their first name, total cost of their items, and the date.
--For simplicity, you can assume that every first name in the dataset is unique.

WITH summary AS (
select o.order_date, o.total_order_cost, first_name from orders AS o
LEFT JOIN customers AS c
ON o.cust_id = c.id
WHERE order_date BETWEEN '2019-02-01' AND '2019-05-01') 

SELECT first_name, SUM(total_order_cost) AS total_order_cost, order_date FROM summary
GROUP BY first_name, order_date
ORDER BY total_order_cost DESC
LIMIT 1;

--Most Profitable Companies
--Find the 3 most profitable companies in the entire world.
--Output the result along with the corresponding company name.
--Sort the result based on profits in descending order.

SELECT company, profits 
FROM forbes_global_2010_2014
GROUP BY company, profits
ORDER BY profits DESC
LIMIT 3;

--ID:9632: Host Popularity Rental Prices
--You’re given a table of rental property searches by users. The table consists of search results and outputs host information for searchers. 
--Find the minimum, average, maximum rental prices for each host’s popularity rating. The host’s popularity rating is defined as below:
/*
    0 reviews: New
    1 to 5 reviews: Rising
    6 to 15 reviews: Trending Up
    16 to 40 reviews: Popular
    more than 40 reviews: Hot
    */

--Tip: The `id` column in the table refers to the search ID. You'll need to create your own host_id by concating price, room_type, host_since, zipcode, and number_of_reviews.
--Output host popularity rating and their minimum, average and maximum rental prices.

WITH rating AS (
SELECT DISTINCT price || room_type || host_since || zipcode || number_of_reviews AS host_id, 
number_of_reviews, price,
CASE WHEN number_of_reviews = 0 THEN 'New'
     WHEN number_of_reviews BETWEEN 1 AND 5 THEN 'Rising'
     WHEN number_of_reviews BETWEEN 6 AND 15 THEN 'Trending Up'
     WHEN number_of_reviews BETWEEN 16 AND 40 THEN 'Popular'
     WHEN number_of_reviews > 40 THEN 'Hot' END AS host_pop_rating
FROM airbnb_host_searches)

SELECT host_pop_rating, MIN(price) AS min_price, AVG(price) AS avg_price, MAX(price) AS max_price
FROM rating
GROUP BY host_pop_rating;

-- ID 10351: Activity Rank
-- Find the email activity rank for each user. Email activity rank is defined by the total number of emails sent. 
-- The user with the highest number of emails sent will have a rank of 1, and so on. Output the user, total emails, and their activity rank. 
-- Order records by the total emails in descending order. Sort users with the same number of emails in alphabetical order.
-- In your rankings, return a unique value (i.e., a unique rank) even if multiple users have the same number of emails.

SELECT from_user, COUNT(id) AS total_email, ROW_NUMBER() OVER (ORDER BY COUNT(id) DESC, from_user) AS Rank
FROM google_gmail_emails
GROUP BY from_user;

-- ID 10314: Revenue Over Time
-- Find the 3-month rolling average of total revenue from purchases given a table with users, their purchase amount, and date purchased. 
-- Do not include returns which are represented by negative purchase values. Output the year-month (YYYY-MM) and 3-month rolling average of revenue, sorted from earliest month to latest month.
-- A 3-month rolling average is defined by calculating the average total revenue from all user purchases for the current month and previous two months. 
-- The first two months will not be a true 3-month rolling average since we are not given data from last year. Assume each month has at least one purchase.

SELECT to_char(created_month,'YYYY-MM') AS month, ROUND(rolling_avg_3mth,3) AS rolling_avg_3mth
FROM (
SELECT created_month, 
AVG(total_purchase_amt) OVER(ORDER BY created_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3mth, ROW_NUMBER() OVER() AS rn
FROM (SELECT DATE_TRUNC('month',created_at) AS created_month, SUM(purchase_amt) AS total_purchase_amt FROM amazon_purchases WHERE purchase_amt > 0 GROUP BY DATE_TRUNC('month',created_at) ORDER BY DATE_TRUNC('month',created_at)) AS a) AS b;

-- ID 10303: Top Percentile Fraud
-- ABC Corp is a mid-sized insurer in the US and in the recent past their fraudulent claims have increased significantly for their personal auto insurance portfolio. 
-- They have developed a ML based predictive model to identify propensity of fraudulent claims. Now, they assign highly experienced claim adjusters for top 5 percentile of claims identified by the model.
-- Your objective is to identify the top 5 percentile of claims from each state. Your output should be policy number, state, claim cost, and fraud score.

SELECT policy_num, state, claim_cost, fraud_score
FROM (
SELECT *, NTILE(100) OVER(PARTITION BY state ORDER BY fraud_score DESC) AS percentile
FROM fraud_score) AS f
WHERE percentile <= 5;

-- ID 10172: Best Selling Item
-- Find the best selling item for each month (no need to separate months by year) where the biggest total invoice was paid. 
-- The best selling item is calculated using the formula (unitprice * quantity). Output the description of the item along with the amount paid.

SELECT invoice_mth, description, amount
FROM (
SELECT EXTRACT(MONTH FROM invoicedate) AS invoice_mth, description, SUM(unitprice*quantity) AS amount, ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM invoicedate) ORDER BY SUM(unitprice*quantity) DESC) AS rn
FROM online_retail
GROUP BY EXTRACT(MONTH FROM invoicedate) , description) AS a
WHERE rn=1;

-- ID 10171: Find the genre of the person with the most number of oscar winnings.
-- If there are more than one person with the same number of oscar wins, return the first one in alphabetic order.

SELECT top_genre
FROM oscar_nominees AS n
LEFT JOIN nominee_information AS i
ON n.nominee = i.name
WHERE winner = TRUE
GROUP BY top_genre
ORDER BY COUNT(*) DESC
LIMIT 1;

-- ID 10090: Find the percentage of shipable orders
-- Find the percentage of shipable orders.
-- Consider an order is shipable if the customer's address is known.

SELECT SUM(address_flag)::NUMERIC/count(*)*100 AS pct_order
FROM (
SELECT o.*, c.city, c.address, c.phone_number,
CASE WHEN address IS NULL THEN 0 ELSE 1 END AS address_flag
FROM orders AS o
LEFT JOIN customers AS c
ON o.id = c.id) AS subquery;
-- ##############################################

-- ID 10069: Correlation Between E-mails And Activity Time
-- There are two tables with user activities. The 'google_gmail_emails` table contains information about emails being sent to users. 
-- Each row in that table represents a message with an unique identifier in the `id` field. The `google_fit_location` table contains user activity logs from the Google Fit app. 
-- Find the correlation between the number of emails received and the total exercise per day. The total exercise per day is calculated by counting the number of user sessions per day.

WITH EMAIL AS (
SELECT to_user, day AS email_day, COALESCE(COUNT(id),0) AS emails FROM google_gmail_emails
GROUP BY to_user, day),
LOCATION AS (
SELECT user_id, day AS exercise_day, COALESCE(COUNT(session_id),0) AS exercise_sessions FROM google_fit_location
GROUP BY user_id, day)

SELECT CORR(emails,exercises) AS correlation
FROM (
SELECT l.user_id, email_day, SUM(emails) AS emails, SUM(exercise_sessions) AS exercises
FROM LOCATION AS l
INNER JOIN EMAIL AS e
ON l.user_id = e.to_user AND l.exercise_day = e.email_day
GROUP BY l.user_id, email_day) AS subquery;
-- ##############################################

-- ID 10297: Comments Distribution
-- Write a query to calculate the distribution of comments by the count of users that joined Meta/Facebook between 2018 and 2020, for the month of January 2020. 
-- The output should contain a count of comments and the corresponding number of users that made that number of comments in Jan-2020. For example, you'll be counting how many users made 1 comment, 2 comments, 3 comments, 4 comments, etc in Jan-2020. 
-- Your left column in the output will be the number of comments while your right column in the output will be the number of users. Sort the output from the least number of comments to highest.
-- To add some complexity, there might be a bug where an user post is dated before the user join date. You'll want to remove these posts from the result.

SELECT comment_cnt, COUNT(id) AS user_cnt
FROM (
SELECT id, COUNT(body) AS comment_cnt
FROM (
SELECT * FROM fb_users AS u
INNER JOIN fb_comments AS c
ON u.id = c.user_id
WHERE DATE_TRUNC('month', DATE(created_at)) = '2020-01-01' AND EXTRACT(YEAR FROM DATE(joined_at)) BETWEEN 2018 AND 2020
AND created_at >= joined_at) AS subquery
GROUP BY id) AS subquery2
GROUP BY comment_cnt;

-- ID 10302: Distance Per Dollar
-- You’re given a dataset of uber rides with the traveling distance (‘distance_to_travel’) and cost (‘monetary_cost’) for each ride. 
-- For each date, find the difference between the distance-per-dollar for that date and the average distance-per-dollar for that year-month. 
-- Distance-per-dollar is defined as the distance traveled divided by the cost of the ride.
-- The output should include the year-month (YYYY-MM) and the absolute average difference in distance-per-dollar (Absolute value to be rounded to the 2nd decimal). 
-- You should also count both success and failed request_status as the distance and cost values are populated for all ride requests. 
-- Also, assume that all dates are unique in the dataset. Order your results by earliest request date first.

WITH MONTHLY AS (
SELECT to_char(DATE_TRUNC('month',request_date),'YYYY-MM') AS request_mnth, SUM(distance_to_travel)/ SUM(monetary_cost) AS distance_per_dollar_mthly
FROM uber_request_logs
GROUP BY request_mnth
ORDER BY request_mnth)

SELECT to_char(DATE_TRUNC('month',request_date),'YYYY-MM') AS request_mnth, ROUND(AVG(difference_daily)::NUMERIC,2) AS difference
FROM 
(
SELECT *, ABS(distance_per_dollar_daily - distance_per_dollar_mthly) AS difference_daily
FROM 
(
SELECT a.request_date, SUM(a.distance_to_travel)/ SUM(a.monetary_cost) AS distance_per_dollar_daily, distance_per_dollar_mthly
FROM uber_request_logs AS a
LEFT JOIN MONTHLY AS m
ON to_char(DATE_TRUNC('month',a.request_date),'YYYY-MM') = m.request_mnth
GROUP BY a.request_date, distance_to_travel, monetary_cost, distance_per_dollar_mthly
ORDER BY a.request_date) AS subquery) AS subquery_l2
GROUP BY to_char(DATE_TRUNC('month',request_date),'YYYY-MM')
ORDER BY to_char(DATE_TRUNC('month',request_date),'YYYY-MM');

-- ID 10062: Fans vs Opposition
--Meta/Facebook is quite keen on pushing their new programming language Hack to all their offices. 
--They ran a survey to quantify the popularity of the language and send it to their employees. 
--To promote Hack they have decided to pair developers which love Hack with the ones who hate it so the fans can convert the opposition. 
--Their pair criteria is to match the biggest fan with biggest opposition, second biggest fan with second biggest opposition, and so on. Write a query which returns this pairing. 
--Output employee ids of paired employees. Sort users with the same popularity value by id in ascending order.
--Duplicates in pairings can be left in the solution. For example, (2, 3) and (3, 2) should both be in the solution.

WITH fan AS (
SELECT *, ROW_NUMBER() OVER(ORDER BY popularity DESC, employee_id)  FROM facebook_hack_survey 
ORDER BY popularity DESC, employee_id),
opposition AS (
SELECT *, ROW_NUMBER() OVER(ORDER BY popularity, employee_id)  FROM facebook_hack_survey 
ORDER BY popularity, employee_id)

SELECT f.employee_id AS employee_fan_id, o.employee_id AS employee_opposition_id
FROM fan AS f
JOIN opposition AS o
ON f.row_number = o.row_number

--ID 9918: Arizona, California, and Hawaii Employees
--Find employees from Arizona, California, and Hawaii while making sure to output all employees from each city. 
--Output column headers should be Arizona, California, and Hawaii. Data for all cities must be ordered on the first name.
--Assume unequal number of employees per city.

WITH arizona AS
(SELECT first_name, ROW_NUMBER() OVER(ORDER BY first_name) FROM employee WHERE city='Arizona' ORDER BY first_name),
california AS
(SELECT first_name, ROW_NUMBER() OVER(ORDER BY first_name) FROM employee WHERE city='California' ORDER BY first_name),
hawaii AS
(SELECT first_name,  ROW_NUMBER() OVER(ORDER BY first_name) FROM employee WHERE city='Hawaii' ORDER BY first_name)

SELECT a.first_name, c.first_name, h.first_name FROM arizona AS a
JOIN california AS c
ON a.row_number = c.row_number
JOIN hawaii AS h
ON a.row_number = h.row_number

--ID 9899: Percentage Of Total Spend
--Calculate the percentage of the total spend a customer spent on each order. Output the customer’s first name, order details, and percentage of the order cost to their total spend across all orders. 
--Assume each customer has a unique first name (i.e., there is only 1 customer named Karen in the dataset) and that customers place at most only 1 order a day.
--Percentages should be represented as fractions

WITH order_data AS (
SELECT DISTINCT first_name, order_details, order_date, total_order_cost AS total_order_cost
FROM orders AS o
LEFT JOIN customers AS c
ON o.cust_id = c.id
GROUP BY first_name, order_details, order_date, total_order_cost),
total_data AS (
SELECT DISTINCT first_name, SUM(total_order_cost) AS total_cost
FROM orders AS o
LEFT JOIN customers AS c
ON o.cust_id = c.id
GROUP BY first_name)

SELECT o.first_name, order_details, SUM(total_order_cost)::NUMERIC/SUM(total_cost) AS percentage_total_cost
FROM order_data AS o
LEFT JOIN total_data AS t
ON o.first_name = t.first_name
GROUP BY o.first_name, order_details, o.order_date, o.total_order_cost
ORDER BY o.first_name, order_details, o.order_date;

--ID 10171: Find the genre of the person with the most number of oscar winnings
--Find the genre of the person with the most number of oscar winnings.
--If there are more than one person with the same number of oscar wins, return the first one in alphabetic order.

SELECT top_genre FROM oscar_nominees AS o
LEFT JOIN nominee_information AS i
ON o.nominee = i.name
WHERE winner = 'TRUE' AND top_genre IS NOT NULL
GROUP BY top_genre, nominee
ORDER BY COUNT(*) DESC
LIMIT 1;

--ID 9865: Highest Salaried Employees
--Find the employee with the highest salary in each department.
--Output the department name, employee's first name, and the salary.

SELECT department, first_name, salary
FROM (
SELECT department, first_name, salary, RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS rank
FROM worker) AS subquery
WHERE rank=1
ORDER BY salary DESC
;