-- StrataScratch Coding Challenge: Hard

--Monthly Percentage Difference
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

--Premium vs Freemium
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

--Popularity Percentage
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

--Top 5 States With 5 Star Businesses
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

--Highest Cost Orders
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

--Host Popularity Rental Prices
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


