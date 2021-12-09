/* SQL Leetcode Challenge - Easy*/

-- Question 21: Actors who cooperated with Directors atleast three times
-- Table: ActorDirector

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | actor_id    | int     |
-- | director_id | int     |
-- | timestamp   | int     |
-- +-------------+---------+
-- timestamp is the primary key column for this table.
 
-- Write a SQL query for a report that provides the pairs (actor_id, director_id) where the actor have cooperated with the director at least 3 times.

-- Example:

-- ActorDirector table:
-- +-------------+-------------+-------------+
-- | actor_id    | director_id | timestamp   |
-- +-------------+-------------+-------------+
-- | 1           | 1           | 0           |
-- | 1           | 1           | 1           |
-- | 1           | 1           | 2           |
-- | 1           | 2           | 3           |
-- | 1           | 2           | 4           |
-- | 2           | 1           | 5           |
-- | 2           | 1           | 6           |
-- +-------------+-------------+-------------+

-- Result table:
-- +-------------+-------------+
-- | actor_id    | director_id |
-- +-------------+-------------+
-- | 1           | 1           |
-- +-------------+-------------+
-- The only pair is (1, 1) where they cooperated exactly 3 times.

CREATE TABLE ActorDirector (
  actor_id INTEGER,
  director_id INTEGER,
  timestamp INTEGER
);

INSERT INTO ActorDirector
  (actor_id, director_id, timestamp)
VALUES
('1','1','0'),
('1','1','1'),
('1','1','2'),
('1','2','3'),
('1','2','4'),
('2','1','5'),
('2','1','6');   

SELECT actor_id, director_id
FROM ActorDirector
GROUP BY actor_id, director_id
HAVING COUNT(CONCAT(actor_id,'_',director_id))>=3;

-- Question 13: Ads performance
-- Table: Ads

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | ad_id         | int     |
-- | user_id       | int     |
-- | action        | enum    |
-- +---------------+---------+
-- (ad_id, user_id) is the primary key for this table.
-- Each row of this table contains the ID of an Ad, the ID of a user and the action taken by this user regarding this Ad.
-- The action column is an ENUM type of ('Clicked', 'Viewed', 'Ignored').
 
-- A company is running Ads and wants to calculate the performance of each Ad.

-- Performance of the Ad is measured using Click-Through Rate (CTR) where:

-- Write an SQL query to find the ctr of each Ad.

-- Round ctr to 2 decimal points. Order the result table by ctr in descending order and by ad_id in ascending order in case of a tie.

-- The query result format is in the following example:

-- Ads table:
-- +-------+---------+---------+
-- | ad_id | user_id | action  |
-- +-------+---------+---------+
-- | 1     | 1       | Clicked |
-- | 2     | 2       | Clicked |
-- | 3     | 3       | Viewed  |
-- | 5     | 5       | Ignored |
-- | 1     | 7       | Ignored |
-- | 2     | 7       | Viewed  |
-- | 3     | 5       | Clicked |
-- | 1     | 4       | Viewed  |
-- | 2     | 11      | Viewed  |
-- | 1     | 2       | Clicked |
-- +-------+---------+---------+
-- Result table:
-- +-------+-------+
-- | ad_id | ctr   |
-- +-------+-------+
-- | 1     | 66.67 |
-- | 3     | 50.00 |
-- | 2     | 33.33 |
-- | 5     | 0.00  |
-- +-------+-------+
-- for ad_id = 1, ctr = (2/(2+1)) * 100 = 66.67
-- for ad_id = 2, ctr = (1/(1+2)) * 100 = 33.33
-- for ad_id = 3, ctr = (1/(1+1)) * 100 = 50.00
-- for ad_id = 5, ctr = 0.00, Note that ad_id = 5 has no clicks or views.
-- Note that we don't care about Ignored Ads.
-- Result table is ordered by the ctr. in case of a tie we order them by ad_id

CREATE TYPE action AS ENUM('Clicked', 'Viewed', 'Ignored');
CREATE TABLE Ads (
  ad_id INTEGER,
  user_id INTEGER,
  action action
);

INSERT INTO Ads
  (ad_id, user_id, action)
VALUES
('1','1','Clicked'),
('2','2','Clicked'),
('3','3','Viewed'),
('5','5','Ignored'),
('1','7','Ignored'),
('2','7','Viewed'),
('3','5','Clicked'),
('1','4','Viewed'),
('2','11','Viewed'),
('1','2','Clicked');

SELECT ad_id, ROUND(SUM(ct_click)::NUMERIC/COUNT(CONCAT(ad_id,'_',user_id))*100,2) as ctr
FROM (
SELECT *, CASE WHEN action = 'Clicked' THEN 1 ELSE 0 END ct_click
FROM Ads) AS subquery
GROUP BY ad_id
ORDER BY ctr DESC;

-- Question 42: Article views
-- Table: Views

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | article_id    | int     |
-- | author_id     | int     |
-- | viewer_id     | int     |
-- | view_date     | date    |
-- +---------------+---------+
-- There is no primary key for this table, it may have duplicate rows.
-- Each row of this table indicates that some viewer viewed an article (written by some author) on some date. 
-- Note that equal author_id and viewer_id indicate the same person.

-- Write an SQL query to find all the authors that viewed at least one of their own articles, sorted in ascending order by their id.

-- The query result format is in the following example:

-- Views table:
-- +------------+-----------+-----------+------------+
-- | article_id | author_id | viewer_id | view_date  |
-- +------------+-----------+-----------+------------+
-- | 1          | 3         | 5         | 2019-08-01 |
-- | 1          | 3         | 6         | 2019-08-02 |
-- | 2          | 7         | 7         | 2019-08-01 |
-- | 2          | 7         | 6         | 2019-08-02 |
-- | 4          | 7         | 1         | 2019-07-22 |
-- | 3          | 4         | 4         | 2019-07-21 |
-- | 3          | 4         | 4         | 2019-07-21 |
-- +------------+-----------+-----------+------------+

-- Result table:
-- +------+
-- | id   |
-- +------+
-- | 4    |
-- | 7    |
-- +------+

CREATE TABLE Views (
  article_id INTEGER,
  author_id INTEGER,
  viewer_id INTEGER,
  view_date DATE
);

INSERT INTO Views
  (article_id, author_id, viewer_id, view_date)
VALUES
('1','3','5','2019-08-01'),
('1','3','6','2019-08-02'),
('2','7','7','2019-08-01'),
('2','7','6','2019-08-02'),
('4','7','1','2019-07-22'),
('3','4','4','2019-07-21'),
('3','4','4','2019-07-21');

SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id;

-- Question 39: Average selling price
-- Table: Prices

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | product_id    | int     |
-- | start_date    | date    |
-- | end_date      | date    |
-- | price         | int     |
-- +---------------+---------+
-- (product_id, start_date, end_date) is the primary key for this table.
-- Each row of this table indicates the price of the product_id in the period from start_date to end_date.
-- For each product_id there will be no two overlapping periods. That means there will be no two intersecting periods for the same product_id.
 
-- Table: UnitsSold

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | product_id    | int     |
-- | purchase_date | date    |
-- | units         | int     |
-- +---------------+---------+
-- There is no primary key for this table, it may contain duplicates.
-- Each row of this table indicates the date, units and product_id of each product sold. 
 
-- Write an SQL query to find the average selling price for each product.
-- average_price should be rounded to 2 decimal places.
-- The query result format is in the following example:

-- Prices table:
-- +------------+------------+------------+--------+
-- | product_id | start_date | end_date   | price  |
-- +------------+------------+------------+--------+
-- | 1          | 2019-02-17 | 2019-02-28 | 5      |
-- | 1          | 2019-03-01 | 2019-03-22 | 20     |
-- | 2          | 2019-02-01 | 2019-02-20 | 15     |
-- | 2          | 2019-02-21 | 2019-03-31 | 30     |
-- +------------+------------+------------+--------+
 
-- UnitsSold table:
-- +------------+---------------+-------+
-- | product_id | purchase_date | units |
-- +------------+---------------+-------+
-- | 1          | 2019-02-25    | 100   |
-- | 1          | 2019-03-01    | 15    |
-- | 2          | 2019-02-10    | 200   |
-- | 2          | 2019-03-22    | 30    |
-- +------------+---------------+-------+

-- Result table:
-- +------------+---------------+
-- | product_id | average_price |
-- +------------+---------------+
-- | 1          | 6.96          |
-- | 2          | 16.96         |
-- +------------+---------------+
-- Average selling price = Total Price of Product / Number of products sold.
-- Average selling price for product 1 = ((100 * 5) + (15 * 20)) / 115 = 6.96
-- Average selling price for product 2 = ((200 * 15) + (30 * 30)) / 230 = 16.96

CREATE TABLE Prices (
  product_id INTEGER,
  start_date DATE,
  end_date DATE,
  price INTEGER
);

CREATE TABLE UnitsSold (
  product_id INTEGER,
  purchase_date DATE,
  units INTEGER
);

INSERT INTO Prices
  (product_id, start_date, end_date, price)
VALUES
('1','2019-02-17','2019-02-28','5'),
('1','2019-03-01','2019-03-22','20'),
('2','2019-02-01','2019-02-20','15'),
('2','2019-02-21','2019-03-31','30');

INSERT INTO UnitsSold
  (product_id, purchase_date, units)
VALUES
('1','2019-02-25','100'),
('1','2019-03-01','15'),
('2','2019-02-10','200'),
('2','2019-03-22','30');

WITH c_table AS (
SELECT u.product_id, units, price
FROM UnitsSold AS u
LEFT JOIN Prices AS p
ON u.product_id = p.product_id
WHERE purchase_date >= start_date AND purchase_date <= end_date)

SELECT product_id, ROUND(SUM(units*price)::NUMERIC/SUM(units),2) AS average_price
FROM c_table
GROUP BY product_id;