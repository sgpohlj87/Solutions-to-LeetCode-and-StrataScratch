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

--ID 9818: File Contents Shuffle
-- Sort the words alphabetically in 'final.txt' and make a new file named 'wacky.txt'. 
-- Output the file contents in one column and the filename 'wacky.txt' in another column.

WITH unnest_list AS (
SELECT UNNEST(STRING_TO_ARRAY(LOWER(contents),' ')) AS word
FROM google_file_store
WHERE filename LIKE 'final%'
ORDER BY word)

SELECT 'wacky.txt' AS filename, ARRAY_TO_STRING(ARRAY_AGG(word),' ') AS contents
FROM unnest_list;

--ID 9855: Find the 5th highest salary without using TOP or LIMIT

SELECT salary
FROM (
SELECT worker_id, salary, RANK() OVER(ORDER BY salary DESC) AS rank
from worker
GROUP BY worker_id, salary) AS s
WHERE rank=5;

--ID 9857: Find the second highest salary without using ORDER BY
SELECT salary
FROM (
SELECT worker_id, salary, MAX(salary) OVER() - salary AS diff_salary_from_max
FROM worker
GROUP BY worker_id, salary
ORDER BY diff_salary_from_max) AS s
WHERE NOT diff_salary_from_max=0
LIMIT 1
;

--ID 9859: Find the first 50% records of the dataset
SELECT *
FROM (
SELECT *, MAX(rn) OVER() AS max_rn
FROM (
SELECT *,ROW_NUMBER() OVER() AS rn
FROM worker) AS s
) AS s2
WHERE rn <= CEIL(max_rn/2);

-- ID 9844: Find all workers who joined on February 2014 
SELECT *
FROM worker
WHERE DATE(DATE_TRUNC('month',joining_date))='2014-02-01';

--ID 9829: Positions Of Letter 'a'
--Find the position of the letter 'a' in the first name of the worker 'Amitah'.
SELECT STRPOS(first_name,'a') 
FROM worker
WHERE first_name = 'Amitah';

--ID 9816: Find the list of intersections between both word lists
WITH unnest_list AS (
SELECT UNNEST(STRING_TO_ARRAY(LOWER(words1),',')) AS words1, 
UNNEST(STRING_TO_ARRAY(LOWER(words2),',')) AS words2
FROM google_word_lists),
word1 AS (SELECT words1 AS words FROM unnest_list),
word2 AS (SELECT words2 AS words FROM unnest_list)

SELECT word1.words FROM word1
INNER JOIN word2
ON word1.words = word2.words;

--ID 10173: Days At Number One
--You have a table with US rankings of tracks and another table with worldwide rankings of tracks.
--Find the number of days a US track has been in the 1st position for both the US and worldwide rankings. 
--Output the track name and the number of days in the 1st position. Order your output alphabetically by track name.

SELECT trackname, COUNT(us_date) AS n_days_on_n1_position
FROM (
SELECT us.trackname, us.artist, us_date, ww_date
FROM (
SELECT trackname, artist, date AS us_date FROM spotify_daily_rankings_2017_us) AS us
FULL JOIN (
SELECT trackname, artist, date AS ww_date FROM spotify_worldwide_daily_song_ranking WHERE region='us') AS ww
ON us.trackname = ww.trackname AND us.artist = ww.artist AND us_date = ww_date
WHERE us_date IS NOT NULL AND ww_date IS NOT NULL) AS subquery
GROUP BY trackname;

--Id 2028: New And Existing Users
--Calculate the share of new and existing users for each month in the table. Output the month, share of new users, and share of existing users as a ratio.
--New users are defined as users who started using services in the current month (there is no usage history in previous months). 
--Existing users are users who used services in current month, but they also used services in any previous month. 
--Assume that the dates are all from the year 2020.

WITH user_data AS (
SELECT EXTRACT(MONTH FROM time_id) AS month, COUNT(DISTINCT user_id) AS cnt_user
FROM fact_events
GROUP BY EXTRACT(MONTH FROM time_id)
),
subset_data AS (
SELECT month, COALESCE(SUM(new_user),0) AS cnt_new_user, COALESCE(SUM(existing_user),0) AS cnt_existing_user
FROM (
SELECT *, CASE WHEN lag_month IS NULL THEN 1 END AS new_user, CASE WHEN lag_month < month THEN 1 END AS existing_user
FROM (
SELECT DISTINCT user_id, EXTRACT(MONTH FROM time_id) AS month, LAG(EXTRACT(MONTH FROM time_id),1) OVER(PARTITION BY user_id ORDER BY EXTRACT(MONTH FROM time_id)) AS lag_month
FROM fact_events
ORDER BY user_id, month, lag_month) AS subquery) AS subquery2
GROUP BY month)

SELECT user_data.month, SUM(cnt_new_user)/SUM(cnt_user) AS share_new_users, SUM(cnt_existing_user)/SUM(cnt_user) AS share_existin_users
FROM user_data
LEFT JOIN subset_data
ON user_data.month = subset_data.month
GROUP BY user_data.month
ORDER BY user_data.month;

--ID 2054: Consecutive Days
--Find all the users who were active for 3 consecutive days or more.

SELECT DISTINCT user_id
FROM (
SELECT *, date-lag_date AS day_lag1, lag_date-lag2_date AS day_lag2
FROM (
SELECT *, LAG(date,1) OVER(PARTITION BY user_id ORDER BY date) AS lag_date,
LAG(date,2) OVER(PARTITION BY user_id ORDER BY date) AS lag2_date
FROM sf_events
ORDER BY user_id, date) AS subquery) AS subquery2
WHERE day_lag1=1 AND day_lag2=1;

--ID 2059: Player with Longest Streak
--You are given a table of tennis players and their matches that they could either win (W) or lose (L). Find the longest streak of wins. 
--A streak is a set of consecutive won matches of one player. 
---The streak ends once a player loses their next match. Output the ID of the player or players and the length of the streak.

---NOT FINALISED YET ---
WITH map AS (
SELECT *, CASE WHEN match_result='W' AND lag_match_result='W' THEN
SUM(win_cnt) OVER(PARTITION BY player_id ORDER BY player_id, match_date) 
ELSE 0 END
AS sum_win_cnt
FROM (
SELECT *, CASE WHEN match_result='W' AND lead_match_result='W' THEN 1 ELSE 0 END AS win_cnt
FROM (
SELECT *, LEAD(match_result) OVER(PARTITION BY player_id ORDER BY match_date) AS lead_match_result, 
LAG(match_result) OVER(PARTITION BY player_id ORDER BY match_date) AS lag_match_result
FROM players_results) AS subquery) AS subquery2)

SELECT player_id, sum_win_cnt+1 AS streak_length
FROM map
WHERE sum_win_cnt = (SELECT max(sum_win_cnt) AS max_sum_win_cnt FROM map)
;

--ID 10313: Naive Forecasting
-- forecasting methods are extremely simple and surprisingly effective. 
--Naïve forecast is one of them; we simply set all forecasts to be the value of the last observation. 
--Our goal is to develop a naïve forecast for a new metric called "distance per dollar" defined as the (distance_to_travel/monetary_cost) in our dataset and measure its accuracy.
--To develop this forecast,  sum "distance to travel"  and "monetary cost" values at a monthly level before calculating "distance per dollar". 
--This value becomes your actual value for the current month. The next step is to populate the forecasted value for each month. 
--This can be achieved simply by getting the previous month's value in a separate column. Now, we have actual and forecasted values. 
--This is your naïve forecast. Let’s evaluate our model by calculating an error matrix called root mean squared error (RMSE). 
--RMSE is defined as sqrt(mean(square(actual - forecast)). Report out the RMSE rounded to the 2nd decimal spot.

WITH data AS (
SELECT *, LAG(actual_distance_per_dollar,1) OVER(ORDER BY request_month) AS forecast_distance_per_dollar
FROM (
SELECT DATE(DATE_TRUNC('month',request_date)) AS request_month, 
SUM(distance_to_travel) AS sum_distance_to_travel,
SUM(monetary_cost) AS sum_monetary_cost, 
SUM(distance_to_travel)::NUMERIC/SUM(monetary_cost) AS actual_distance_per_dollar
FROM uber_request_logs
--WHERE request_status='success'
GROUP BY DATE(DATE_TRUNC('month',request_date))
ORDER BY DATE(DATE_TRUNC('month',request_date))
) AS subquery)

SELECT ROUND(SQRT(AVG((actual_distance_per_dollar-forecast_distance_per_dollar)*(actual_distance_per_dollar-forecast_distance_per_dollar)))::NUMERIC,2) AS RMSE
FROM data;

--ID 10081: Find the number of employees who received the bonus and who didn't
--Find the number of employees who received the bonus and who didn't.
--Output an indication of whether the bonus was received or not along with the corresponding number of employees.
--ex: if the bonus was received: 1, if not: 0.

SELECT has_bonus, COUNT(DISTINCT id) AS n_employees 
FROM (
SELECT *, CASE WHEN worker_ref_id IS NULL THEN 0 ELSE 1 END AS has_bonus
FROM employee AS e
LEFT JOIN bonus AS b
ON e.id = b.worker_ref_id) AS subquery
GROUP BY has_bonus;

--ID 2090: First Day Retention Rate
--Calculate the first-day retention rate of a group of video game players. 
--The first-day retention occurs when a player logs in on a day following their first-ever log-in.
--Return the proportion of players who meet this definition divided by the total number of players. 

WITH retention AS (
SELECT DISTINCT player_id AS retention_id
FROM (
SELECT *
FROM (
SELECT *, LAG(login_date,1) OVER (PARTITION BY player_id ORDER BY login_date) AS lag_login_date FROM players_logins) AS subquery
WHERE login_date - lag_login_date=1) AS subquery2),
full_data AS (
SELECT DISTINCT player_id FROM players_logins)

SELECT COUNT(DISTINCT retention_id)::NUMERIC/COUNT(DISTINCT player_id) AS retention_rate
FROM retention FULL JOIN full_data
ON retention_id = player_id

--ID 9900: Median Salary
--Find the median employee salary of each department.
--Output the department name along with the corresponding salary rounded to the nearest whole dollar.

SELECT department, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
FROM employee
GROUP BY department;

--ID 10013: Positive Ad Channels
--Find the advertising channel with the smallest maximum yearly spending that still brings in more than 1500 customers each year.

WITH below_1500 AS (
SELECT advertising_channel 
FROM uber_advertising
GROUP BY advertising_channel
HAVING MIN(customers_acquired) > 1500),
ranking AS 
(SELECT u.advertising_channel, money_spent,
dense_rank() OVER (PARTITION BY u.advertising_channel ORDER BY money_spent DESC) AS rank
FROM uber_advertising AS u
INNER JOIN below_1500 b ON u.advertising_channel = b.advertising_channel
),
rank1 AS (
SELECT * FROM ranking WHERE rank=1)

SELECT advertising_channel
FROM rank1
WHERE money_spent = 
(SELECT MIN(money_spent) FROM rank1);

--ID 9815: Price Of A Handyman
--Find the price that a small handyman business is willing to pay per employee. 
--Get the result based on the mode of the adword earnings per employee distribution. 
--Small businesses are considered to have not more than ten employees.

SELECT adword_earnings_per_employee
FROM (
SELECT business_type, n_employees, year, adwords_earnings, 
SUM(adwords_earnings)/SUM(n_employees) AS adword_earnings_per_employee
FROM google_adwords_earnings
WHERE business_type='handyman' AND n_employees <=10
GROUP BY business_type, n_employees, year, adwords_earnings) AS subquery
GROUP BY adword_earnings_per_employee
ORDER BY COUNT(*) DESC
LIMIT 1
;

--ID 514: Marketing Campaign Success [Advanced]
--You have a table of in-app purchases by user. 
--Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. Find the number of users that made additional in-app purchases due to the success of the marketing campaign.
--The marketing campaign doesn't start until one day after the initial in-app purchase so users that make multiple purchases on the same day do not count, nor do we count users that over time purchase only the products they purchased on the first day.

SELECT COUNT(DISTINCT user_id)
FROM (
SELECT user_id, product_id
FROM (
SELECT *, 
MIN(created_at) OVER(PARTITION BY user_id ORDER BY created_at) AS first_date, 
FIRST_VALUE(product_id) OVER(PARTITION BY user_id ORDER BY created_at) AS first_product, CONCAT(user_id,product_id) AS user_pdt
FROM marketing_campaign
GROUP BY user_id, product_id, created_at, quantity, price
)AS subquery
WHERE NOT (created_at = first_date OR product_id = first_product)
GROUP BY user_id, product_id
HAVING COUNT(user_pdt)=1) AS subquery2;

--ID 9736: Highest Number Of High-risk Violations
--Find details of the business with the highest number of high-risk violations. 
--Output all columns from the dataset considering business_id which consist 'high risk' phrase in risk_category column.

WITH high_risk AS (
SELECT * FROM sf_restaurant_health_violations
WHERE risk_category='High Risk'),
high_risk_cnt AS (
SELECT business_id
FROM high_risk
GROUP BY business_id
ORDER BY COUNT(*) DESC
LIMIT 1)

SELECT high_risk.*
FROM high_risk
INNER JOIN high_risk_cnt
ON high_risk.business_id = high_risk_cnt.business_id

--ID 9822: Find the average number of friends a user has
SELECT AVG(cnt) AS avg_fr
FROM (
SELECT user_id, COUNT(friend_id) AS cnt
FROM (
SELECT user_id,friend_id
FROM google_friends_network
UNION 
SELECT friend_id,user_id
FROM google_friends_network) AS subquery
GROUP BY user_id) AS subquery2

--ID 9637: Growth of Airbnb
--Estimate the growth of Airbnb each year using the number of hosts registered as the growth metric. 
--The rate of growth is calculated by taking ((number of hosts registered in the current year - number of hosts registered in the previous year) / the number of hosts registered in the previous year) * 100.
--Output the year, number of hosts in the current year, number of hosts in the previous year, and the rate of growth. 
--Round the rate of growth to the nearest percent and order the result in the ascending order based on the year.
--Assume that the dataset consists only of unique hosts, meaning there are no duplicate hosts listed.

SELECT *, ROUND((current_year_host-prev_year_host)*100::NUMERIC/prev_year_host,0) AS estimated_growth
FROM (
SELECT EXTRACT(YEAR FROM host_since) AS year, COUNT(DISTINCT id) AS current_year_host, LAG(COUNT(DISTINCT id)) OVER(ORDER BY EXTRACT(YEAR FROM host_since)) AS prev_year_host
FROM airbnb_search_details
GROUP BY EXTRACT(YEAR FROM host_since)) AS subquery

--ID 9919: Unique Highest Salary
--Find the highest salary among salaries that appears only once.

select MAX(salary) from employee;

--ID 9966: Quarterback With The Longest Throw
--Find the quarterback who threw the longest throw in 2016. 
--Output the quarterback name along with their corresponding longest throw. 
--The 'lg' column contains the longest completion by the quarterback.

WITH qb_list AS (
SELECT qb, REPLACE(lg,'t','')::NUMERIC AS lg_num FROM qbstats_2015_2016
WHERE year=2016),
max_qb AS (SELECT MAX(lg_num) AS max_lg_num FROM qb_list)

SELECT qb_list.* FROM qb_list
RIGHT JOIN max_qb
ON lg_num = max_lg_num

--ID 9775: Liking Score Rating
--Find how the number of `likes` are increasing by building a `like` score based on `like` propensities. 
--A `like` propensity is defined as the probability of giving a like amongst all reactions, per friend (i.e., number of likes / number of all reactions).
--Output the average propensity alongside the corresponding date and poster. Sort the result based on the liking score in descending order.
--In `facebook_reactions` table `poster` is user who posted a content, `friend` is a user who saw the content and reacted. The `facebook_friends` table stores pairs of connected friends.

WITH p AS (
SELECT friend,
SUM(CASE WHEN reaction='like' THEN 1 END)::NUMERIC/COUNT(reaction) AS prop
FROM facebook_reactions
GROUP BY friend)

SELECT date_day, poster, avg(prop) AS avg
FROM facebook_reactions f
JOIN p ON f.friend= p.friend
GROUP BY date_day, poster
ORDER BY avg DESC


--ID 9608: Exclusive Amazon Products
--Find products which are exclusive to only Amazon and therefore not sold at Top Shop and Macy's. Your output should include the product name, brand name, price, and rating.
--Two products are considered equal if they have the same product name and same maximum retail price (mrp column).

SELECT product_name,brand_name,price,rating
FROM innerwear_amazon_com
WHERE product_name||mrp 
NOT IN (SELECT DISTINCT product_name||mrp FROM innerwear_macys_com
UNION ALL
SELECT DISTINCT product_name||mrp FROM innerwear_topshop_com
)

--ID 9606: Differences In Movie Ratings
--Calculate the average lifetime rating and rating from the movie with second biggest id across all actors and all films they had acted in - role type is "Normal Acting". 
--Output a list of actors, their average lifetime rating, rating from the film with the second biggest id (use id column), and the absolute difference between the two ratings.
WITH lifetime AS (
SELECT name, AVG(rating) AS lifetime_rating FROM nominee_filmography
WHERE role_type = 'Normal Acting' AND rating IS NOT NULL
GROUP BY name),
second_last AS (
SELECT name, rating AS second_last_rating
FROM (
SELECT name, rating, id, ROW_NUMBER() OVER(PARTITION BY name ORDER BY id DESC) AS rn FROM nominee_filmography
WHERE role_type = 'Normal Acting' AND rating IS NOT NULL
GROUP BY name, rating, id) AS subquery
WHERE rn=2)

SELECT second_last.*, lifetime_rating, ABS(second_last_rating-lifetime_rating) AS variance FROM second_last
LEFT JOIN lifetime
ON second_last.name = lifetime.name
WHERE second_last_rating IS NOT NULL

--ID 9605: Find the average rating of movie stars
--Find the average rating of each movie star along with their names and birthdays. Sort the result in the ascending order based on the birthday. 
--Use the names as keys when joining the tables.

SELECT birthday, film.name, AVG(rating) AS avg_rating FROM nominee_filmography AS film
LEFT JOIN nominee_information AS info
ON film.name = info.name
GROUP BY birthday, film.name;

--ID 9603: Find fare differences on the Titanic using a self join
--Find the average absolute fare difference between a specific passenger and all passengers that belong to the same pclass,  both are non-survivors and age difference between two of them is 5 or less years. 
--Do that for each passenger (that satisfy above mentioned coniditions). Output the result along with the passenger name.

SELECT
    titanic1.name AS name1,
    AVG(ABS(titanic1.fare - titanic2.fare)) AS avg_fare
FROM 
    titanic titanic1,
    titanic titanic2
WHERE
    titanic1.passengerid <> titanic2.passengerid AND
    titanic1.pclass = titanic2.pclass AND
    ABS(titanic1.age - titanic2.age) <= 5 AND
    titanic1.survived = 0 AND 
    titanic2.survived = 0
GROUP BY 
    name1

--ID 2112: Product Market Share
--Write a query to find the Market Share at the Product Brand level for each Territory, for Time Period Q4-2021. 
--Market Share is the number of Products of a certain Product Brand brand sold in a territory, divided by the total number of Products sold in this Territory.
--Output the ID of the Territory, name of the Product Brand and the corresponding Market Share in percentages. Only include these Product Brands that had at least one sale in a given territory.

WITH prod_brand AS (
SELECT territory_id, prod_brand, COUNT(DISTINCT order_id) AS prod_cnt FROM fct_customer_sales AS sales
LEFT JOIN map_customer_territory AS map
ON sales.cust_id = map.cust_id
LEFT JOIN dim_product AS product
ON sales.prod_sku_id = product.prod_sku_id
WHERE order_date BETWEEN '2021-10-01' AND '2021-12-31'
GROUP BY territory_id, prod_brand),
territory AS (
SELECT territory_id, COUNT(DISTINCT order_id) AS territory_cnt FROM fct_customer_sales AS sales
LEFT JOIN map_customer_territory AS map
ON sales.cust_id = map.cust_id
LEFT JOIN dim_product AS product
ON sales.prod_sku_id = product.prod_sku_id
WHERE order_date BETWEEN '2021-10-01' AND '2021-12-31'
GROUP BY territory_id)

SELECT territory_id, prod_brand, SUM(prod_cnt::NUMERIC)*100/SUM(territory_cnt::NUMERIC) AS market_share
FROM (
SELECT prod_brand.*, territory_cnt
FROM prod_brand
LEFT JOIN territory
ON prod_brand.territory_id = territory.territory_id) AS subquery
GROUP BY territory_id, prod_brand
ORDER BY territory_id, market_share

--ID 2111: Sales Growth per Territory
--Write a query to return Territory and corresponding Sales Growth. Compare growth between periods Q4-2021 vs Q3-2021.
--If Territory (say T123) has Sales worth $100 in Q3-2021 and Sales worth $110 in Q4-2021, then the Sales Growth will be 10% [ i.e. = ((110 - 100)/100) * 100 ]
--Output the ID of the Territory and the Sales Growth. Only output these territories that had any sales in both quarters.

SELECT territory_id, SUM(sales-lag_sales)*100/SUM(lag_sales) AS sales_growth
FROM (
SELECT territory_id, Quarter, SUM(order_value) AS sales, LAG(SUM(order_value),1) OVER(PARTITION BY territory_id ORDER BY  Quarter ASC) AS lag_sales
FROM (
SELECT *,
CASE WHEN order_date BETWEEN '2021-07-01' AND '2021-09-30' THEN 'Q3-2021'
     WHEN order_date BETWEEN '2021-10-01' AND '2021-12-31' THEN 'Q4-2021' END AS Quarter
FROM fct_customer_sales AS sales
LEFT JOIN map_customer_territory AS map
ON sales.cust_id = map.cust_id
WHERE order_date BETWEEN '2021-07-01' AND '2021-12-31') AS subquery
GROUP BY territory_id, Quarter) AS subquery
WHERE sales IS NOT NULL AND lag_sales IS NOT NULL
GROUP BY territory_id

-- ID 2103: Reviewed flags of top videos
-- For the video (or videos) that received the most user flags, how many of these flags were reviewed by YouTube? Output the video ID and the corresponding number of reviewed flags.

WITH rank AS (
SELECT video_id, COUNT(DISTINCT user_flags.flag_id) AS cnt, RANK() OVER(ORDER BY COUNT(DISTINCT user_flags.flag_id) DESC)  AS rn FROM user_flags
LEFT JOIN flag_review
ON user_flags.flag_id = flag_review.flag_id
GROUP BY video_id
ORDER BY cnt DESC)

SELECT video_id, COUNT(user_flags.flag_id) AS num_flags_reviewed_by_yt
FROM user_flags
LEFT JOIN flag_review
ON user_flags.flag_id = flag_review.flag_id
WHERE video_id IN (SELECT video_id FROM rank WHERE rn=1)
AND reviewed_by_yt=TRUE
GROUP BY video_id

--ID 2089: Cookbook Recipes
--You are given the table with titles of recipes from a cookbook and their page numbers. You are asked to represent how the recipes will be distributed in the book.
--Produce a table consisting of three columns: left_page_number, left_title and right_title. The k-th row (counting from 0), should contain the number and the title of the page with the number 2 \times k2×k in the first and second columns respectively, and the title of the page with the number 2 \times k + 12×k+1 in the third column.
--Each page contains at most 1 recipe. If the page does not contain a recipe, the appropriate cell should remain empty (NULL value). Page 0 (the internal side of the front cover) is guaranteed to be empty.

WITH page_numbers AS (
   SELECT generate_series(0,(SELECT max(page_number) FROM cookbook_titles)) AS page_number
),
page_titles AS (
  SELECT 
      page_number AS left_page_number, 
      title AS left_title,
      LEAD(title,1) OVER(ORDER BY page_number) AS right_title
  FROM page_numbers
  LEFT JOIN cookbook_titles USING (page_number)
)

SELECT *
FROM page_titles
WHERE left_page_number % 2 = 0

--ID 9634: Host Response Rates With Cleaning Fees
--Find the average host response rate with a cleaning fee for each zipcode. Present the results as a percentage along with the zip code value.
--Convert the column 'host_response_rate' from TEXT to NUMERIC using type casts and string processing (take missing values as NULL).
--Order the result in ascending order based on the average host response rater after cleaning.

SELECT zipcode, AVG(CAST(REPLACE(host_response_rate,'%','') AS NUMERIC)) AS avg_host_response_rate 
FROM airbnb_search_details
WHERE cleaning_fee = TRUE 
GROUP BY zipcode
HAVING AVG(CAST(REPLACE(host_response_rate,'%','') AS NUMERIC)) IS NOT NULL
ORDER BY avg_host_response_rate

--ID 10145:Make a pivot table to find the highest payment in each year for each employee
--Make a pivot table to find the highest payment in each year for each employee.
--Find payment details for 2011, 2012, 2013, and 2014.
--Output payment details along with the corresponding employee name.
--Order records by the employee name in ascending order

SELECT employeename, MAX(pay_2011) AS pay_2011, MAX(pay_2012) AS pay_2012, MAX(pay_2013) AS pay_2013, MAX(pay_2014) AS pay_2014
FROM (
SELECT employeename,
    CASE WHEN year=2011 THEN totalpay ELSE 0 END AS pay_2011,
    CASE WHEN year=2012 THEN totalpay ELSE 0 END AS pay_2012,
    CASE WHEN year=2013 THEN totalpay ELSE 0 END AS pay_2013,
    CASE WHEN year=2014 THEN totalpay ELSE 0 END AS pay_2014
FROM sf_public_salaries) AS subquery
GROUP BY employeename
ORDER BY employeename

--ID 10045: Points Rating Of Wines Over Time
--Find the average points difference between each and previous years starting from the year 2000. Output the year, average points, previous average points, and the difference between them.
--If you're unable to calculate the average points rating for a specific year, use an 87 average points rating for that year (which is the average of all wines starting from 2000).

SELECT year, COALESCE(AVG(points),87) AS avg_points, COALESCE(LAG(COALESCE(AVG(points),87)) OVER(ORDER BY year),87) AS prev_avg_points, COALESCE(AVG(points),87) - COALESCE(LAG(COALESCE(AVG(points),87)) OVER(ORDER BY year),87) AS difference
FROM (
select *, substring(title FROM '20[0-9][0-9]') AS year from winemag_p2) AS subquery
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year

--ID 2078: From Microsoft to Google
--Consider all LinkedIn users who, at some point, worked at Microsoft. For how many of them was Google their next employer right after Microsoft (no employers in between)?

SELECT COUNT(DISTINCT user_id)
FROM (
SELECT *, LEAD(employer,1) OVER (PARTITION BY user_id ORDER BY start_date) AS lead_employer
FROM linkedin_users) AS subquery
WHERE employer = 'Microsoft' AND lead_employer = 'Google'

--ID 2076: Trips in Consecutive Months
--Find the IDs of the drivers who completed at least one trip a month for at least two months in a row.

SELECT *, DATE(LAG(trip_month,1) OVER (PARTITION BY driver_id ORDER BY trip_month)) AS lag_trip_month
FROM (
SELECT driver_id, DATE(DATE_TRUNC('month',trip_date)) AS trip_month, SUM(CASE WHEN is_completed='TRUE' THEN 1 END) AS num_trips
FROM uber_trips
GROUP BY driver_id, trip_month
ORDER BY driver_id, trip_month) AS subquery
WHERE num_trips > 0

--ID 2029:The Most Popular Client_Id Among Users Using Video and Voice Calls
--Select the most popular client_id based on a count of the number of users who have at least 50% of their events from the following list: 'video call received', 'video call sent', 'voice call received', 'voice call sent'.

SELECT client_id
FROM (
SELECT client_id, user_id,
COUNT(DISTINCT CASE WHEN event_type IN ('video call received','video call sent','voice call received','voice call sent') THEN event_id END) AS cnt_event_id_selected,
COUNT(DISTINCT event_id) AS cnt_event_id,
COUNT(DISTINCT CASE WHEN event_type IN ('video call received','video call sent','voice call received','voice call sent') THEN event_id END)*100 / COUNT(DISTINCT event_id) AS pct
FROM fact_events
GROUP BY client_id, user_id) AS subquery
WHERE pct > 50
GROUP BY client_id
ORDER BY COUNT(DISTINCT user_id) DESC
LIMIT 1

--ID 9883: Find the oldest survivor per passenger class
--Find the oldest survivor of each passenger class.
--Output the name and the age of the survivor along with the corresponding passenger class.
--Order records by passenger class in ascending order

SELECT name, age, pclass
FROM (
SELECT *, MAX(age) OVER(PARTITION BY pclass ORDER BY age DESC) AS max_age_per_class
FROM titanic
WHERE survived=1) AS sub
WHERE age=max_age_per_class
ORDER BY pclass

--ID 9793: Average Time Between Steps
--Find the average time (in seconds), per product, that needed to progress between steps. You can ignore products that were never used. Output the feature id and the average time.

SELECT feature_id, AVG(avg_diff)
FROM (
SELECT feature_id, user_id, AVG(diff) AS avg_diff
FROM (
SELECT *, EXTRACT(EPOCH FROM timestamp::TIMESTAMP - lag_timestamp::TIMESTAMP) AS diff
FROM (
SELECT *, LAG(timestamp,1) OVER (PARTITION BY feature_id, user_id ORDER BY step_reached) AS lag_timestamp
FROM facebook_product_features_realizations
) AS subquery
) AS subquery2
GROUP BY feature_id, user_id
HAVING AVG(diff) IS NOT NULL
) AS subquery3
GROUP BY feature_id

--ID 9763:Most Popular Room Types
--Find the room types that are searched by most people. Output the room type alongside the number of searches for it.
--If the filter for room types has more than one room type, consider each unique room type as a separate row. Sort the result based on the number of searches in descending order.

SELECT room_types, SUM(n_searches) AS sum_searches
FROM (
SELECT DISTINCT *, UNNEST(STRING_TO_ARRAY(LTRIM(filter_room_types,','),',')) AS room_types 
FROM airbnb_searches) AS sub
GROUP BY room_types
ORDER BY sum_searches DESC

--ID 10043: Median Price Of Wines
--Find the median price for each wine variety across both datasets. Output distinct varieties along with the corresponding median price. 

WITH combine_winemag AS (
SELECT variety, price
FROM winemag_p1
UNION ALL
SELECT variety, price
FROM winemag_p2)

SELECT DISTINCT variety, percentile_cont(0.5) within GROUP (ORDER BY price) AS median_price
FROM combine_winemag
GROUP BY variety

---ID 10042: Top 3 Wineries In The World
---Find the top 3 wineries in each country based on the average points earned. In case there is a tie, order the wineries by winery name in ascending order. 
---Output the country along with the best, second best, and third best wineries. 
--If there is no second winery (NULL value) output 'No second winery' and if there is no third winery output 'No third winery'. 
---For outputting wineries format them like this: "winery (avg_points)"

WITH rank_data AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY country ORDER BY avg_pts DESC) AS rank_pts
FROM (
SELECT country, winery, ROUND(AVG(points),0) AS avg_pts
FROM winemag_p1
GROUP BY country, winery
) AS sub
) ,
first_wine AS (
SELECT country, winery||' ('||avg_pts||')' AS top_winery
FROM rank_data
WHERE rank_pts=1),
second_wine AS (
SELECT country, winery||' ('||avg_pts||')' AS second_winery
FROM rank_data
WHERE rank_pts=2),
third_wine AS (
SELECT country, winery||' ('||avg_pts||')' AS third_winery
FROM rank_data
WHERE rank_pts=3),
list_of_country AS (
SELECT DISTINCT country
FROM rank_data
)

SELECT list_of_country.country, top_winery, COALESCE(second_winery,'No second winery') AS second_winery, COALESCE(third_winery,'No third winery') AS third_winery
FROM list_of_country
JOIN first_wine
ON list_of_country.country = first_wine.country
JOIN second_wine
ON list_of_country.country = second_wine.country
JOIN third_wine
ON list_of_country.country = third_wine.country
ORDER BY list_of_country.country

--ID 2008: The Cheapest Airline Connection
--COMPANY X employees are trying to find the cheapest flights to upcoming conferences. 
--When people fly long distances, a direct city-to-city flight is often more expensive than taking two flights with a stop in a hub city. 
---Travelers might save even more money by breaking the trip into three flights with two stops. But for the purposes of this challenge, 
--let's assume that no one is willing to stop three times! You have a table with individual airport-to-airport flights, which contains the following columns:

--• id - the unique ID of the flight;
--• origin - the origin city of the current flight;
--• destination - the destination city of the current flight;
--• cost - the cost of current flight.

--Your task is to produce a trips table that lists all the cheapest possible trips that can be done in two or fewer stops. 
--This table should have the columns origin, destination and total_cost (cheapest one). Sort the output table by origin, then by destination. 
--The cities are all represented by an abbreviation composed of three uppercase English letters. 
---Note: A flight from SFO to JFK is considered to be different than a flight from JFK to SFO.

--Example of the output:
--origin | destination | total_cost
---DFW | JFK | 200

WITH connection AS (
    SELECT flt1.origin AS origin1, flt1.destination AS destination1, flt1.cost AS cost1,
                 flt2.origin AS origin2, flt2.destination AS destination2, flt2.cost AS cost2,
                 flt3.origin AS origin3, flt3.destination AS destination3, flt3.cost AS cost3
    FROM da_flights AS flt1
    LEFT JOIN da_flights AS flt2 ON flt1.destination = flt2.origin
    LEFT JOIN da_flights  AS flt3 ON flt2.destination = flt3.origin
),
list_of_flights AS (
    SELECT origin1 AS origin, destination1 AS destination, cost1 AS cost
    FROM connection
    UNION ALL
    SELECT origin1 AS origin, destination2 AS destination2, cost1 + cost2 AS cost
    FROM connection
    UNION ALL
    SELECT origin1 AS origin, destination3 AS destination3, cost1 + cost2 + cost3 AS cost
    FROM connection
)

SELECT origin, destination, min(cost) AS total_cost
FROM list_of_flights
WHERE destination IS NOT NULL AND cost IS NOT NULL
GROUP BY origin, destination

--ID 9711: Facilities With Lots Of Inspections
--Find the facility that got the highest number of inspections in 2017 compared to other years. 
---Compare the number of inspections per year and output only facilities that had the number of inspections greater in 2017 than in any other year.
---Each row in the dataset represents an inspection. Base your solution on the facility name and activity date fields.

SELECT DISTINCT facility_name
FROM (
SELECT facility_name, EXTRACT(year FROM activity_date) AS activity_year,
RANK() OVER (PARTITION BY facility_name ORDER BY COUNT(DISTINCT serial_number) DESC) AS rank, COUNT(DISTINCT serial_number) AS count
FROM los_angeles_restaurant_health_inspections
GROUP BY facility_name, EXTRACT(year FROM activity_date) 
) AS subquery
WHERE activity_year = 2017 AND rank=1

--ID 9989: Highest Paid City Employees
--Find the top 2 highest paid City employees for each job title. Output the job title along with the corresponding highest and second-highest paid employees.

WITH data AS (
SELECT jobtitle, employeename, rnk
FROM (
SELECT *, ROW_NUMBER() OVER (PARTITION BY jobtitle ORDER BY totalpaybenefits DESC) AS rnk
FROM sf_public_salaries
) AS sub
WHERE rnk <= 2)

SELECT best.jobtitle, best, second_best
FROM (
SELECT jobtitle, employeename AS best
FROM data
WHERE rnk=1) AS best
LEFT JOIN 
(SELECT jobtitle, employeename AS second_best
FROM data
WHERE rnk=2) AS second_best
ON best.jobtitle = second_best.jobtitle

--ID 9981: Employees Without Benefits
--Find the ratio between the number of employees without benefits to total employees. 
--Output the job title, number of employees without benefits, total employees relevant to that job title, and the corresponding ratio. 
--Order records based on the ratio in ascending order.

WITH data AS (
SELECT DISTINCT employeename, jobtitle,
CASE WHEN benefits = 0 THEN 0 ELSE 1 END AS benefit_flag
FROM sf_public_salaries),
without_benefit AS (
SELECT jobtitle AS left_job, COALESCE(COUNT(DISTINCT employeename),0) AS cnt_employee_without_benefit
FROM data
WHERE benefit_flag = 0
GROUP BY jobtitle),
with_benefit AS (
SELECT jobtitle AS right_job, COALESCE(COUNT(DISTINCT employeename),0) AS cnt_employee_with_benefit
FROM data
WHERE benefit_flag = 1
GROUP BY jobtitle)

SELECT with_benefit.jobtitle, cnt_employee_without_benefits, 
cnt_employee_without_benefits+cnt_employee_with_benefits AS total_people, 
cnt_employee_without_benefits::NUMERIC/cnt_employee_with_benefits AS rto
FROM with_benefit
LEFT JOIN without_benefit
ON with_benefit.jobtitle= without_benefit.jobtitle

--ID 9979: Find the top 5 highest paid and top 5 least paid employees in 2012
--Find the top 5 highest paid and top 5 least paid employees in 2012.
--Output the employee name along with the corresponding total pay with benefits.
--Sort records based on the total payment with benefits in ascending order.

SELECT employeename, totalpaybenefits
FROM (
SELECT employeename, totalpaybenefits, ROW_NUMBER() OVER (ORDER BY totalpaybenefits ASC) AS rank_asc,
ROW_NUMBER() OVER (ORDER BY totalpaybenefits DESC) AS rank_desc
FROM sf_public_salaries
WHERE year=2012) AS sub
WHERE rank_asc <=5 OR rank_desc <= 5
ORDER BY totalpaybenefits

--ID 9716: Top 3 Facilities
--Find the top 3 facilities for each owner. The top 3 facilities can be identified using the highest average score for each owner name and facility address grouping.
--The output should include 4 columns: owner name, top 1 facility address, top 2 facility address, and top 3 facility address. Order facilities with the same score alphabetically.

WITH rank_data AS (
SELECT owner_name, facility_address, ROW_NUMBER() OVER (PARTITION BY owner_name
ORDER BY AVG(score) DESC) AS rank_avg_score
FROM los_angeles_restaurant_health_inspections
GROUP BY owner_name, facility_address)

SELECT rank1.owner_name, facility_1, facility_2, facility_3
FROM (
SELECT owner_name, facility_address AS facility_1
FROM rank_data
WHERE rank_avg_score=1
) AS rank1
LEFT JOIN (
SELECT owner_name, facility_address AS facility_2
FROM rank_data
WHERE rank_avg_score=2
) AS rank2
ON rank1.owner_name = rank2.owner_name
LEFT JOIN (
SELECT owner_name, facility_address AS facility_3
FROM rank_data
WHERE rank_avg_score=3
) AS rank3
ON rank1.owner_name = rank3.owner_name

--ID 9985: Above Average But Not At The Top
--Find all people who earned more than the average in 2013 for their designation but were not amongst the top 5 earners for their job title. 
--Use the totalpay column to calculate total earned and output the employee name(s) as the result.

WITH average_2013 AS (
SELECT jobtitle, AVG(totalpay) AS avg_totalpay
FROM sf_public_salaries
WHERE year=2013
GROUP BY jobtitle),
employee_pay AS (
SELECT employeename, jobtitle, totalpay, ROW_NUMBER() OVER (PARTITION BY jobtitle
ORDER BY totalpay DESC) AS rnk
FROM sf_public_salaries
WHERE year=2013
)

SELECT employeename
FROM employee_pay
LEFT JOIN average_2013
ON employee_pay.jobtitle = average_2013.jobtitle
WHERE employee_pay.totalpay > average_2013.avg_totalpay
AND rnk > 5

--ID 10017: Year Over Year Churn
--Find how the number of drivers that have churned changed in each year compared to the previous one. 
--Output the year (specifically, you can use the year the driver left Lyft) along with the corresponding number of churns in that year, the number of churns in the previous year, and an indication on whether the number has been increased (output the value 'increase'), decreased (output the value 'decrease') or stayed the same (output the value 'no change').

SELECT *,
CASE WHEN n_churned > n_churned_prev THEN 'increase'
     WHEN n_churned < n_churned_prev THEN 'decrease'
     WHEN n_churned = n_churned_prev THEN 'no change' END AS case
FROM (
SELECT EXTRACT(year FROM end_date) AS year_driver_churned, COUNT(DISTINCT index) AS n_churned,
COALESCE(LAG(COUNT(DISTINCT index),1) OVER (ORDER BY EXTRACT(year FROM end_date) ASC),0)
AS n_churned_prev
FROM lyft_drivers
WHERE end_date IS NOT NULL
GROUP BY EXTRACT(year FROM end_date)
) sub

--ID 9986: Find the top 5 least paid employees for each job title
--Find the top 5 least paid employees for each job title.
--Output the employee name, job title and total pay with benefits for the first 5 least paid employees. Avoid gaps in ranking.

SELECT employeename, jobtitle, totalpaybenefits
FROM (
SELECT employeename, jobtitle, totalpaybenefits, 
ROW_NUMBER() OVER (PARTITION BY jobtitle ORDER BY totalpaybenefits ASC) AS rnk
FROM sf_public_salaries) AS sub
WHERE rnk <= 5

---ID 9977: Find the number of police officers, firefighters, and medical staff employees
--Find the number of police officers (job title contains substring police), firefighters (job title contains substring fire), and medical staff employees (job title contains substring medical) based on the employee name.
---Output each job title along with the corresponding number of employees.

SELECT position, COUNT(DISTINCT id) AS n_employees
FROM (
SELECT id,
CASE WHEN LOWER(jobtitle) LIKE '%police%' THEN 'Police'
     WHEN LOWER(jobtitle) LIKE '%fire%' THEN 'Firefighter'
     WHEN LOWER(jobtitle) LIKE '%medical%' THEN 'Medical Staff' END AS position
FROM sf_public_salaries
WHERE LOWER(jobtitle) LIKE '%police%' OR 
LOWER(jobtitle) LIKE '%fire%' OR LOWER(jobtitle) LIKE '%medical%') AS sub
GROUP BY position

--ID 10019: Find the percentage of rides for each weather and the hour
--Find the percentage of rides each weather-hour combination constitutes among all weather-hour combinations.
--Output the weather, hour along with the corresponding percentage.

SELECT weather, hour, n_rides::NUMERIC/SUM(n_rides) OVER() AS probability
FROM (
SELECT weather, hour, COUNT(INDEX) AS n_rides
FROM lyft_rides
GROUP BY weather, hour
ORDER BY weather, hour) AS sub

--ID 2044: Most Senior & Junior Employee
--Write a query to find the number of days between the longest and least tenured employee still working for the company. 
---Your output should include the number of employees with the longest-tenure, the number of employees with the least-tenure, and the number of days between both the longest-tenured and least-tenured hiring dates.

SELECT
  (SELECT count(id)
   FROM uber_employees
   WHERE hire_date = most_hire_date
   and termination_date IS NULL) AS shortest_tenured_count,

  (SELECT count(id)
   FROM uber_employees
   WHERE hire_date = least_hire_date
   and termination_date IS NULL) AS longest_tenured_count,

  (most_hire_date - least_hire_date) AS days_diff

FROM
  (SELECT max(hire_date) AS most_hire_date,
          min(hire_date) AS least_hire_date
   FROM uber_employees
   WHERE termination_date IS NULL ) tmp


---ID 9955: Norwegian Alpine Skiers
--Find all Norwegian alpine skiers who participated in 1992 but didn't participate in 1994. Output unique athlete names.

WITH name_1992 AS (
SELECT DISTINCT name
FROM olympics_athletes_events
WHERE year = 1992
),
name_1994 AS (
SELECT DISTINCT name
FROM olympics_athletes_events
WHERE year = 1994
)

SELECT name_1992.name
FROM name_1992
WHERE NOT EXISTS
(SELECT name FROM name_1994 WHERE name_1992.name = name_1994.name
)

--ID 9814: Counting Instances in Text
--Find the number of times the words 'bull' and 'bear' occur in the contents. 
--We're counting the number of times the words occur so words like 'bullish' should not be included in our count.
--Output the word 'bull' and 'bear' along with the corresponding number of occurrences.

SELECT word, COUNT(*) AS nentry
FROM (
select filename, LOWER(unnest(string_to_array(contents, ' '))) word from google_file_store) AS sub
WHERE word IN ('bull','bear')
GROUP BY word

--ID 2087: Negative Reviews in New Locations

--Find stores that were opened in the second half of 2021 with more than 20% of their reviews being negative. 
--A review is considered negative when the score given by a customer is below 5. Output the names of the stores together with the ratio of negative reviews to positive ones.

WITH data AS
(SELECT store_id, name, score,
CASE WHEN score < 5 THEN 1 ELSE 0 END AS is_negative
   FROM instacart_reviews r
   JOIN instacart_stores s ON r.store_id = s.id
   WHERE opening_date BETWEEN '2021-07-01' AND '2021-12-31') 
   
   
SELECT name, sum(is_negative) / (CAST(count(*) AS FLOAT) - sum(is_negative)) AS negative_ratio
FROM data
GROUP BY name
HAVING sum(is_negative) / CAST(count(*) AS FLOAT) > 0.2

--ID 2136: Customer Tracking
--Given the users' sessions logs on a particular day, calculate how many hours each user was active that day.
--Note: The session starts when state=1 and ends when state=0.

WITH time_data AS (
SELECT *,
CASE WHEN state_lag =1 AND state = 0 THEN 
EXTRACT(EPOCH FROM CAST(timestamp AS TIME) - CAST(timestamp_lag AS TIME)) END AS timestamp_diff
FROM (
SELECT *,
LAG(timestamp,1) OVER (PARTITION BY cust_id ORDER BY timestamp ASC) AS timestamp_lag,
LAG(state,1) OVER (PARTITION BY cust_id ORDER BY timestamp ASC) AS state_lag
FROM cust_tracking) AS sub)

SELECT cust_id, SUM(timestamp_diff)/3600 AS total_time_diff
FROM time_data
GROUP BY cust_id
ORDER BY cust_id

--ID 9957: Find how the average male height changed between each Olympics from 1896 to 2016

--Find how the average male height changed between each Olympics from 1896 to 2016.
--Output the Olympics year, average height, previous average height, and the corresponding average height difference.
--Order records by the year in ascending order.
--If avg height is not found, assume that the average height of an athlete is 172.73.

SELECT *, avg_height - prev_avg_height AS avg_height_diff
FROM (
SELECT *,
COALESCE(LAG(avg_height,1) OVER (ORDER BY year ASC), 172.73) AS prev_avg_height
FROM (
SELECT year, AVG(height) AS avg_height 
FROM 
(SELECT DISTINCT year, id, height, sex
      FROM olympics_athletes_events) AS athlete
WHERE year BETWEEN 1896 AND 2016 AND sex='M'
GROUP BY year
ORDER BY year) AS sub) AS sub2

--ID 9953: Olympics Gender Ratio
--Find the gender ratio between the number of men and women who participated in each Olympics.
--Output the Olympics name along with the corresponding number of men, women, and the gender ratio. 
--If there are Olympics with no women, output a NULL instead of a ratio.

SELECT *, total_men::FLOAT/total_women AS gender_ratio
FROM (
SELECT games,
COUNT(DISTINCT CASE WHEN sex='M' THEN id END) AS total_men,
COUNT(DISTINCT CASE WHEN sex='F' THEN id END) AS total_women
FROM olympics_athletes_events
GROUP BY games
HAVING COUNT(DISTINCT CASE WHEN sex='F' THEN id END) > 0) AS sub

--ID 2115: More Than 100 Dollars
--For each month of 2021, calculate what percentage of restaurants, out of these that fulfilled any orders in a given month, fulfilled more than 100$ in monthly sales?

SELECT month, 100*SUM(total_sum_100_flag)::FLOAT/COUNT(DISTINCT restaurant_id) AS perc_over_100
FROM (
SELECT restaurant_id, EXTRACT(MONTH FROM order_placed_time) AS month, SUM(sales_amount) AS total_sales,
CASE WHEN SUM(sales_amount) > 100 THEN 1 ELSE 0 END AS total_sum_100_flag
FROM delivery_orders AS d
LEFT JOIN order_value AS v
ON d.delivery_id = v.delivery_id
WHERE EXTRACT(YEAR FROM order_placed_time) = 2021
GROUP BY restaurant_id, EXTRACT(MONTH FROM order_placed_time)) AS sub
GROUP BY month

--ID 2038: WFM Brand Segmentation based on Customer Activity
--WFM would like to segment the customers in each of their store brands into Low, Medium, and High segmentation. 
--The segments are to be based on a customer's average basket size which is defined as (total sales / count of transactions), per customer.

--The segment thresholds are as follows:
---If average basket size is more than $30, then Segment is “High”.
---If average basket size is between $20 and $30, then Segment is “Medium”.
---If average basket size is less than $20, then Segment is “Low”.

--Summarize the number of unique customers, the total number of transactions, total sales, and average basket size, grouped by store brand and segment for 2017.
--Your output should include the brand, segment, number of customers, total transactions, total sales, and average basket size.

WITH data AS (
SELECT customer_id, store_brand, 
CASE WHEN SUM(sales)::FLOAT/COUNT(DISTINCT transaction_id) > 30 THEN 'High'
    WHEN SUM(sales)::FLOAT/COUNT(DISTINCT transaction_id) BETWEEN 20 AND 30 THEN 'Medium'
    WHEN SUM(sales)::FLOAT/COUNT(DISTINCT transaction_id) < 20 THEN 'Low' END AS segment,
COUNT(DISTINCT transaction_id) AS total_transactions, SUM(sales) AS total_sales,
SUM(sales)::FLOAT/COUNT(DISTINCT transaction_id) AS avg_basket_size
FROM wfm_transactions AS t
LEFT JOIN wfm_stores AS s
ON t.store_id = s.store_id
WHERE EXTRACT(YEAR FROM transaction_date)=2017
GROUP BY customer_id, store_brand)

SELECT store_brand AS brand, segment, COUNT(DISTINCT customer_id) AS total_customers,
SUM(total_transactions) AS total_transactions, SUM(total_sales) AS total_sales,
SUM(total_sales)/SUM(total_transactions) AS avg_basket_size
FROM data
GROUP BY store_brand, segment


--ID 9739: Worst Businesses
--For every year, find the worst business in the dataset. The worst business has the most violations during the year. You should output the year, business name, and number of violations.

SELECT inspection_year, business_name, violation_count
FROM (
SELECT *, MAX(violation_count) OVER (PARTITION BY inspection_year) AS max_count
FROM (
SELECT EXTRACT(year FROM inspection_date) AS inspection_year, business_name, COUNT(DISTINCT violation_id) AS violation_count
FROM sf_restaurant_health_violations
GROUP BY EXTRACT(year FROM inspection_date), business_name
ORDER BY EXTRACT(year FROM inspection_date), business_name) AS sub) AS sub2
WHERE violation_count = max_count

--ID 9714: Find the latest inspection date for the most sanitary restaurant(s). 
--Assume the most sanitary restaurant is the one with the highest number of points received in any inspection (not just the last one). 
--Only businesses with 'restaurant' in the name should be considered in your analysis.
--Output the corresponding facility name, inspection score, latest inspection date, previous inspection date, and the difference between the latest and previous inspection dates. 
--And order the records based on the latest inspection date in ascending order.

WITH most_sanitary AS
SELECT DISTINCT facility_name, score
FROM (
SELECT *, MAX(score) OVER() AS max_score 
FROM los_angeles_restaurant_health_inspections
WHERE LOWER(facility_name) LIKE '%restaurant%') AS sub
WHERE score = max_score),
inspection_date AS (
SELECT facility_name, activity_date, prev_activity_date, activity_date - prev_activity_date AS num_of_days_between
FROM (
SELECT facility_name, activity_date, LEAD(activity_date,1) OVER (PARTITION BY facility_name ORDER BY activity_date DESC) AS prev_activity_date, 
ROW_NUMBER() OVER (PARTITION BY facility_name ORDER BY activity_date DESC) AS rn
FROM los_angeles_restaurant_health_inspections
WHERE LOWER(facility_name) LIKE '%restaurant%') AS sub
WHERE rn <= 2)

--ID 10302: Distance Per Dollar
--You’re given a dataset of uber rides with the traveling distance (‘distance_to_travel’) and cost (‘monetary_cost’) for each ride. 
--For each date, find the difference between the distance-per-dollar for that date and the average distance-per-dollar for that year-month. 
--Distance-per-dollar is defined as the distance traveled divided by the cost of the ride.
--The output should include the year-month (YYYY-MM) and the absolute average difference in distance-per-dollar (Absolute value to be rounded to the 2nd decimal).
--You should also count both success and failed request_status as the distance and cost values are populated for all ride requests. Also, assume that all dates are unique in the dataset. 
--Order your results by earliest request date first.

WITH data AS (
SELECT *, ABS(distance_per_dollar - avg_distance_per_dollar) AS difference
FROM (
SELECT *, AVG(distance_per_dollar) OVER (PARTITION BY request_month) AS avg_distance_per_dollar
FROM (
SELECT *, DATE_FORMAT(request_date,'%Y-%m') AS request_month, distance_to_travel/monetary_cost AS distance_per_dollar 
FROM uber_request_logs
ORDER BY request_date) AS sub) AS sub2)

SELECT request_month, ROUND(AVG(difference),2) AS avg_difference
FROM data
GROUP BY request_month
ORDER BY request_month

--ID 2073: The column 'perc_viewed' in the table 'post_views' denotes the percentage of the session duration time the user spent viewing a post. 
---Using it, calculate the total time that each post was viewed by users. 
---Output post ID and the total viewing time in seconds, but only for posts with a total viewing time of over 5 seconds.

SELECT post_id, SUM(log_session) AS total_log_session
FROM (
SELECT *, EXTRACT(EPOCH FROM session_endtime - session_starttime)*perc_viewed/100 AS log_session
FROM user_sessions 
RIGHT JOIN post_views 
ON user_sessions.session_id = post_views.session_id) AS sub
GROUP BY post_id
HAVING SUM(log_session) > 5
ORDER BY post_id

--ID 10037: Find each taster's favorite wine variety.
--Consider that favorite variety means the variety that has been tasted by most of the time.
--Output the taster's name along with the wine variety

SELECT taster_name, variety
FROM (
SELECT *, RANK() OVER (PARTITION BY taster_name ORDER BY sum_pts DESC) AS rn
FROM (
SELECT taster_name, variety, SUM(points) AS sum_pts
FROM winemag_p2
GROUP BY taster_name, variety) AS sub) AS sub2
WHERE rn=1