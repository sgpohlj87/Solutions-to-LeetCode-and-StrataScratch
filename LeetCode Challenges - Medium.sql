/* SQL Leetcode Challenge - Medium*/

-- Question 65: Active Businesses

-- Table: Events
-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | business_id   | int     |
-- | event_type    | varchar |
-- | occurences    | int     | 
-- +---------------+---------+
-- (business_id, event_type) is the primary key of this table.
-- Each row in the table logs the info that an event of some type occured at some business for a number of times.
 

-- Write an SQL query to find all active businesses.

-- An active business is a business that has more than one event type with occurences greater than the average occurences of that event type among all businesses.

-- The query result format is in the following example:

-- Events table:
-- +-------------+------------+------------+
-- | business_id | event_type | occurences |
-- +-------------+------------+------------+
-- | 1           | reviews    | 7          |
-- | 3           | reviews    | 3          |
-- | 1           | ads        | 11         |
-- | 2           | ads        | 7          |
-- | 3           | ads        | 6          |
-- | 1           | page views | 3          |
-- | 2           | page views | 12         |
-- +-------------+------------+------------+

-- Result table:
-- +-------------+
-- | business_id |
-- +-------------+
-- | 1           |
-- +-------------+ 
-- Average for 'reviews', 'ads' and 'page views' are (7+3)/2=5, (11+7+6)/3=8, (3+12)/2=7.5 respectively.
-- Business with id 1 has 7 'reviews' events (more than 5) and 11 'ads' events (more than 8) so it is an active business.

CREATE TABLE Events (
  business_id INTEGER,
  event_type VARCHAR(20),
  occurences INTEGER
);

INSERT INTO Events
  (business_id, event_type, occurences)
VALUES
  ('1', 'reviews', '7'),
  ('3', 'reviews', '3'),
  ('1', 'ads', '11'),
  ('2', 'ads', '7'),
  ('3', 'ads', '6'),
  ('1', 'page views', '3'),
  ('2', 'page views', '12');

WITH average_occurence AS (
    SELECT event_type, ROUND(AVG(occurences),2) AS avg_occ
    FROM Events
    GROUP BY event_type
)

SELECT E.business_id
FROM Events as E
INNER JOIN average_occurence AS A
ON E.event_type = A.event_type
WHERE occurences > avg_occ
GROUP BY E.business_id
HAVING COUNT(*)>1;

-- Question 94: Active Users

-- Table Accounts:

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | name          | varchar |
-- +---------------+---------+
-- the id is the primary key for this table.
-- This table contains the account id and the user name of each account.
 
-- Table Logins:

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | login_date    | date    |
-- +---------------+---------+
-- There is no primary key for this table, it may contain duplicates.
-- This table contains the account id of the user who logged in and the login date. A user may log in multiple times in the day.
 

-- Write an SQL query to find the id and the name of active users.

-- Active users are those who logged in to their accounts for 5 or more consecutive days.

-- Return the result table ordered by the id.

-- The query result format is in the following example:

-- Accounts table:
-- +----+----------+
-- | id | name     |
-- +----+----------+
-- | 1  | Winston  |
-- | 7  | Jonathan |
-- +----+----------+

-- Logins table:
-- +----+------------+
-- | id | login_date |
-- +----+------------+
-- | 7  | 2020-05-30 |
-- | 1  | 2020-05-30 |
-- | 7  | 2020-05-31 |
-- | 7  | 2020-06-01 |
-- | 7  | 2020-06-02 |
-- | 7  | 2020-06-02 |
-- | 7  | 2020-06-03 |
-- | 1  | 2020-06-07 |
-- | 7  | 2020-06-10 |
-- +----+------------+

-- Result table:
-- +----+----------+
-- | id | name     |
-- +----+----------+
-- | 7  | Jonathan |
-- +----+----------+
-- User Winston with id = 1 logged in 2 times only in 2 different days, so, Winston is not an active user.
-- User Jonathan with id = 7 logged in 7 times in 6 different days, five of them were consecutive days, so, Jonathan is an active user.

CREATE TABLE Accounts (
  id INTEGER,
  name VARCHAR(100)
);

CREATE TABLE Logins (
  id INTEGER,
  login_date DATE
);

INSERT INTO Accounts
  (id, name)
VALUES
  ('1', 'Winston'),
  ('7', 'Jonathan');

INSERT INTO Logins
  (id, login_date)
VALUES
('7','2020-05-30'),
('1','2020-05-30'),
('7','2020-05-31'),
('7','2020-06-01'),
('7','2020-06-02'),
('7','2020-06-02'),
('7','2020-06-03'),
('1','2020-06-07'),
('7','2020-06-10');
  
SELECT id FROM (
SELECT id, login_date, LAG(login_date,1)  OVER  (PARTITION BY  id ORDER BY id,login_date) as lag_login_date
FROM Logins) AS subquery
WHERE login_date::DATE-lag_login_date::DATE=1
GROUP BY id
HAVING COUNT(*) >=4;

-- Question 77: Activity Participants
-- Table: Friends

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | name          | varchar |
-- | activity      | varchar |
-- +---------------+---------+
-- id is the id of the friend and primary key for this table.
-- name is the name of the friend.
-- activity is the name of the activity which the friend takes part in.
-- Table: Activities

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | name          | varchar |
-- +---------------+---------+
-- id is the primary key for this table.
-- name is the name of the activity.
 

-- Write an SQL query to find the names of all the activities with neither maximum, nor minimum number of participants.

-- Return the result table in any order. Each activity in table Activities is performed by any person in the table Friends.

-- The query result format is in the following example:

-- Friends table:
-- +------+--------------+---------------+
-- | id   | name         | activity      |
-- +------+--------------+---------------+
-- | 1    | Jonathan D.  | Eating        |
-- | 2    | Jade W.      | Singing       |
-- | 3    | Victor J.    | Singing       |
-- | 4    | Elvis Q.     | Eating        |
-- | 5    | Daniel A.    | Eating        |
-- | 6    | Bob B.       | Horse Riding  |
-- +------+--------------+---------------+

-- Activities table:
-- +------+--------------+
-- | id   | name         |
-- +------+--------------+
-- | 1    | Eating       |
-- | 2    | Singing      |
-- | 3    | Horse Riding |
-- +------+--------------+

-- Result table:
-- +--------------+
-- | activity     |
-- +--------------+
-- | Singing      |
-- +--------------+

-- Eating activity is performed by 3 friends, maximum number of participants, (Jonathan D. , Elvis Q. and Daniel A.)
-- Horse Riding activity is performed by 1 friend, minimum number of participants, (Bob B.)
-- Singing is performed by 2 friends (Victor J. and Jade W.)

CREATE TABLE Friends (
  id INTEGER,
  name VARCHAR(100),
  activity VARCHAR(100)
);

CREATE TABLE Activities (
  id INTEGER,
  name VARCHAR(100)
);

INSERT INTO Friends
  (id, name, activity)
VALUES
('1','Jonathan D.','Eating'),
('2','Jade W.','Singing'),
('3','Victor J.','Singing'),
('4','Elvis Q.','Eating'),
('5','Daniel A.','Eating'),
('6','Bob B.','Horse Riding');

INSERT INTO Activities 
  (id, name)
VALUES
('1','Eating'),
('2','Singing'),
('3','Horse Riding');
  
WITH activity_count AS (
SELECT activity, COUNT(activity) AS count_activity
FROM Friends
GROUP BY activity
ORDER BY count_activity)

SELECT activity FROM activity_count
WHERE NOT count_activity = (SELECT MIN(count_activity) FROM activity_count) AND
NOT count_activity = (SELECT MAX(count_activity) FROM activity_count);

-- Question 55: All people report to the given manager
-- Table: Employees

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | employee_id   | int     |
-- | employee_name | varchar |
-- | manager_id    | int     |
-- +---------------+---------+
-- employee_id is the primary key for this table.
-- Each row of this table indicates that the employee with ID employee_id and name employee_name reports his
-- work to his/her direct manager with manager_id
-- The head of the company is the employee with employee_id = 1.
 
-- Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.

-- The indirect relation between managers will not exceed 3 managers as the company is small.

-- Return result table in any order without duplicates.

-- The query result format is in the following example:

-- Employees table:
-- +-------------+---------------+------------+
-- | employee_id | employee_name | manager_id |
-- +-------------+---------------+------------+
-- | 1           | Boss          | 1          |
-- | 3           | Alice         | 3          |
-- | 2           | Bob           | 1          |
-- | 4           | Daniel        | 2          |
-- | 7           | Luis          | 4          |
-- | 8           | Jhon          | 3          |
-- | 9           | Angela        | 8          |
-- | 77          | Robert        | 1          |
-- +-------------+---------------+------------+

-- Result table:
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 2           |
-- | 77          |
-- | 4           |
-- | 7           |
-- +-------------+

-- The head of the company is the employee with employee_id 1.
-- The employees with employee_id 2 and 77 report their work directly to the head of the company.
-- The employee with employee_id 4 report his work indirectly to the head of the company 4 --> 2 --> 1. 
-- The employee with employee_id 7 report his work indirectly to the head of the company 7 --> 4 --> 2 --> 1.
-- The employees with employee_id 3, 8 and 9 don't report their work to head of company directly or indirectly.

CREATE TABLE Employees (
  employee_id INTEGER,
  employee_name VARCHAR(100),
  manager_id INTEGER
);

INSERT INTO Employees
  (employee_id, employee_name, manager_id)
VALUES
('1','Boss','1'),
('3','Alice','3'),
('2','Bob','1'),
('4','Daniel','2'),
('7','Luis','4'),
('8','Jhon','3'),
('9','Angela','8'),
('77','Robert','1');


-- Question 66: Apples & Oranges
-- Table: Sales

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | sale_date     | date    |
-- | fruit         | enum    | 
-- | sold_num      | int     | 
-- +---------------+---------+
-- (sale_date,fruit) is the primary key for this table.
-- This table contains the sales of "apples" and "oranges" sold each day.
 

-- Write an SQL query to report the difference between number of apples and oranges sold each day.

-- Return the result table ordered by sale_date in format ('YYYY-MM-DD').

-- The query result format is in the following example:

-- Sales table:
-- +------------+------------+-------------+
-- | sale_date  | fruit      | sold_num    |
-- +------------+------------+-------------+
-- | 2020-05-01 | apples     | 10          |
-- | 2020-05-01 | oranges    | 8           |
-- | 2020-05-02 | apples     | 15          |
-- | 2020-05-02 | oranges    | 15          |
-- | 2020-05-03 | apples     | 20          |
-- | 2020-05-03 | oranges    | 0           |
-- | 2020-05-04 | apples     | 15          |
-- | 2020-05-04 | oranges    | 16          |
-- +------------+------------+-------------+

-- Result table:
-- +------------+--------------+
-- | sale_date  | diff         |
-- +------------+--------------+
-- | 2020-05-01 | 2            |
-- | 2020-05-02 | 0            |
-- | 2020-05-03 | 20           |
-- | 2020-05-04 | -1           |
-- +------------+--------------+

-- Day 2020-05-01, 10 apples and 8 oranges were sold (Difference  10 - 8 = 2).
-- Day 2020-05-02, 15 apples and 15 oranges were sold (Difference 15 - 15 = 0).
-- Day 2020-05-03, 20 apples and 0 oranges were sold (Difference 20 - 0 = 20).
-- Day 2020-05-04, 15 apples and 16 oranges were sold (Difference 15 - 16 = -1).

CREATE TYPE fruit AS ENUM('apples','oranges');

CREATE TABLE Sales (
	sale_date DATE,
    fruit fruit,
    sold_num INTEGER
);

INSERT INTO Sales
  (sale_date, fruit, sold_num)
VALUES
('2020-05-01','apples','10'),
('2020-05-01','oranges','8'),
('2020-05-02','apples','15'),
('2020-05-02','oranges','15'),
('2020-05-03','apples','20'),
('2020-05-03','oranges','0'),
('2020-05-04','apples','15'),
('2020-05-04','oranges','16');

SELECT a.sale_date, a.sold_num-b.sold_num AS diff
FROM 
((SELECT * FROM Sales WHERE fruit = 'apples') AS a
JOIN
(SELECT * FROM Sales WHERE  fruit = 'oranges') AS b
on a.sale_date = b.sale_date) 

-- Question 81: Article Views 2
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
 
-- Write an SQL query to find all the people who viewed more than one article on the same date, sorted in ascending order by their id.

-- The query result format is in the following example:

-- Views table:
-- +------------+-----------+-----------+------------+
-- | article_id | author_id | viewer_id | view_date  |
-- +------------+-----------+-----------+------------+
-- | 1          | 3         | 5         | 2019-08-01 |
-- | 3          | 4         | 5         | 2019-08-01 |
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
-- | 5    |
-- | 6    |
-- +------+

CREATE TABLE Views (
	article_id INTEGER,
    author_id INTEGER,
    viewer_id  INTEGER,
    view_date DATE
);

INSERT INTO Views
  (article_id, author_id, viewer_id, view_date)
VALUES
('1','3','5','2019-08-01'),
('3','4','5','2019-08-01'),
('1','3','6','2019-08-02'),
('2','7','7','2019-08-01'),
('2','7','6','2019-08-02'),
('4','7','1','2019-07-22'),
('3','4','4','2019-07-21'),
('3','4','4','2019-07-21');

SELECT viewer_id
FROM Views
GROUP BY view_date, viewer_id
HAVING COUNT (DISTINCT article_id)>1;

-- Question 74: Calculate Salaries
-- Table Salaries:

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | company_id    | int     |
-- | employee_id   | int     |
-- | employee_name | varchar |
-- | salary        | int     |
-- +---------------+---------+
-- (company_id, employee_id) is the primary key for this table.
-- This table contains the company id, the id, the name and the salary for an employee.
 

-- Write an SQL query to find the salaries of the employees after applying taxes.

-- The tax rate is calculated for each company based on the following criteria:

-- 0% If the max salary of any employee in the company is less than 1000$.
-- 24% If the max salary of any employee in the company is in the range [1000, 10000] inclusive.
-- 49% If the max salary of any employee in the company is greater than 10000$.
-- Return the result table in any order. Round the salary to the nearest integer.

-- The query result format is in the following example:

-- Salaries table:
-- +------------+-------------+---------------+--------+
-- | company_id | employee_id | employee_name | salary |
-- +------------+-------------+---------------+--------+
-- | 1          | 1           | Tony          | 2000   |
-- | 1          | 2           | Pronub        | 21300  |
-- | 1          | 3           | Tyrrox        | 10800  |
-- | 2          | 1           | Pam           | 300    |
-- | 2          | 7           | Bassem        | 450    |
-- | 2          | 9           | Hermione      | 700    |
-- | 3          | 7           | Bocaben       | 100    |
-- | 3          | 2           | Ognjen        | 2200   |
-- | 3          | 13          | Nyancat       | 3300   |
-- | 3          | 15          | Morninngcat   | 1866   |
-- +------------+-------------+---------------+--------+

-- Result table:
-- +------------+-------------+---------------+--------+
-- | company_id | employee_id | employee_name | salary |
-- +------------+-------------+---------------+--------+
-- | 1          | 1           | Tony          | 1020   |
-- | 1          | 2           | Pronub        | 10863  |
-- | 1          | 3           | Tyrrox        | 5508   |
-- | 2          | 1           | Pam           | 300    |
-- | 2          | 7           | Bassem        | 450    |
-- | 2          | 9           | Hermione      | 700    |
-- | 3          | 7           | Bocaben       | 76     |
-- | 3          | 2           | Ognjen        | 1672   |
-- | 3          | 13          | Nyancat       | 2508   |
-- | 3          | 15          | Morninngcat   | 5911   |
-- +------------+-------------+---------------+--------+
-- For company 1, Max salary is 21300. Employees in company 1 have taxes = 49%
-- For company 2, Max salary is 700. Employees in company 2 have taxes = 0%
-- For company 3, Max salary is 7777. Employees in company 3 have taxes = 24%
-- The salary after taxes = salary - (taxes percentage / 100) * salary
-- For example, Salary for Morninngcat (3, 15) after taxes = 7777 - 7777 * (24 / 100) = 7777 - 1866.48 = 5910.52, which is rounded to 5911.

CREATE TABLE Salaries (
	company_id INTEGER,
    employee_id INTEGER,
    employee_name  VARCHAR(100),
    salary INTEGER
);

INSERT INTO Salaries
  (company_id, employee_id, employee_name, salary)
VALUES
('1','1','Tony','2000'),
('1','2','Pronub','21300'),
('1','3','Tyrrox','10800'),
('2','1','Pam','300'),
('2','7','Bassem','450'),
('2','9','Hermione','700'),
('3','7','Bocaben','100'),
('3','2','Ognjen','2200'),
('3','13','Nyancat','3300'),
('3','15','Morninngcat','1866');

WITH Reference_Table AS(
SELECT company_id, MAX(salary) AS max_salary,
CASE WHEN MAX(salary)<1000 THEN 0
		  WHEN MAX(salary)>=1000 AND MAX(salary)<=10000 THEN 0.24
          WHEN MAX(salary)>10000 THEN 0.49 END AS Tax
FROM Salaries GROUP BY company_id)

SELECT s.company_id, s.employee_id, s.employee_name, ROUND(salary - (Tax*salary),0) AS salary_tax
FROM Salaries AS s
LEFT JOIN Reference_Table AS t
ON s.company_id = t.company_id;

-- Question 61: Capital Gain
-- Table: Stocks

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | stock_name    | varchar |
-- | operation     | enum    |
-- | operation_day | int     |
-- | price         | int     |
-- +---------------+---------+
-- (stock_name, day) is the primary key for this table.
-- The operation column is an ENUM of type ('Sell', 'Buy')
-- Each row of this table indicates that the stock which has stock_name had an operation on the day operation_day with the price.
-- It is guaranteed that each 'Sell' operation for a stock has a corresponding 'Buy' operation in a previous day.
 
-- Write an SQL query to report the Capital gain/loss for each stock.

-- The capital gain/loss of a stock is total gain or loss after buying and selling the stock one or many times.

-- Return the result table in any order.

-- The query result format is in the following example:

-- Stocks table:
-- +---------------+-----------+---------------+--------+
-- | stock_name    | operation | operation_day | price  |
-- +---------------+-----------+---------------+--------+
-- | Leetcode      | Buy       | 1             | 1000   |
-- | Corona Masks  | Buy       | 2             | 10     |
-- | Leetcode      | Sell      | 5             | 9000   |
-- | Handbags      | Buy       | 17            | 30000  |
-- | Corona Masks  | Sell      | 3             | 1010   |
-- | Corona Masks  | Buy       | 4             | 1000   |
-- | Corona Masks  | Sell      | 5             | 500    |
-- | Corona Masks  | Buy       | 6             | 1000   |
-- | Handbags      | Sell      | 29            | 7000   |
-- | Corona Masks  | Sell      | 10            | 10000  |
-- +---------------+-----------+---------------+--------+

-- Result table:
-- +---------------+-------------------+
-- | stock_name    | capital_gain_loss |
-- +---------------+-------------------+
-- | Corona Masks  | 9500              |
-- | Leetcode      | 8000              |
-- | Handbags      | -23000            |
-- +---------------+-------------------+
-- Leetcode stock was bought at day 1 for 1000$ and was sold at day 5 for 9000$. Capital gain = 9000 - 1000 = 8000$.
-- Handbags stock was bought at day 17 for 30000$ and was sold at day 29 for 7000$. Capital loss = 7000 - 30000 = -23000$.
-- Corona Masks stock was bought at day 1 for 10$ and was sold at day 3 for 1010$. It was bought again at day 4 for 1000$ and was sold at day 5 for 500$. At last, it was bought at day 6 for 1000$ and was sold at day 10 for 10000$. Capital gain/loss is the sum of capital gains/losses for each ('Buy' --> 'Sell') 
-- operation = (1010 - 10) + (500 - 1000) + (10000 - 1000) = 1000 - 500 + 9000 = 9500$.

CREATE TYPE operation AS ENUM('Buy','Sell');

CREATE TABLE Stocks (
	stock_name VARCHAR(20),
    operation operation,
    operation_day INTEGER,
    price INTEGER
);

INSERT INTO Stocks
  (stock_name, operation, operation_day, price)
VALUES
('Leetcode','Buy','1','1000'),
('CoronaMasks','Buy','2','10'),
('Leetcode','Sell','5','9000'),
('Handbags','Buy','17','30000'),
('CoronaMasks','Sell','3','1010'),
('CoronaMasks','Buy','4','1000'),
('CoronaMasks','Sell','5','500'),
('CoronaMasks','Buy','6','1000'),
('Handbags','Sell','29','7000'),
('CoronaMasks','Sell','10','10000');

WITH Total_Stocks AS (
SELECT stock_name, operation, SUM(price) AS total_price
FROM Stocks
GROUP BY stock_name, operation)

SELECT b.stock_name, s.total_price - b.total_price AS capital_gain_loss
FROM (
(SELECT * FROM Total_Stocks WHERE operation='Buy') AS b
JOIN 
(SELECT * FROM Total_Stocks WHERE operation='Sell') AS s
ON b.stock_name = s.stock_name);

-- Question 52: Consecutive Numbers
-- Write a SQL query to find all numbers that appear at least three times consecutively.

-- +----+-----+
-- | Id | Num |
-- +----+-----+
-- | 1  |  1  |
-- | 2  |  1  |
-- | 3  |  1  |
-- | 4  |  2  |
-- | 5  |  1  |
-- | 6  |  2  |
-- | 7  |  2  |
-- +----+-----+
-- For example, given the above Logs table, 1 is the only number that appears consecutively for at least three times.

-- +-----------------+
-- | ConsecutiveNums |
-- +-----------------+
-- | 1               |
-- +-----------------+

..........................

-- Question 87: Count student number in departments
-- A university uses 2 data tables, student and department, to store data about its students
-- and the departments associated with each major.

-- Write a query to print the respective department name and number of students majoring in each
-- department for all departments in the department table (even ones with no current students).

-- Sort your results by descending number of students; if two or more departments have the same number of students, 
-- then sort those departments alphabetically by department name.

-- The student is described as follow:

-- | Column Name  | Type      |
-- |--------------|-----------|
-- | student_id   | Integer   |
-- | student_name | String    |
-- | gender       | Character |
-- | dept_id      | Integer   |
-- where student_id is the student's ID number, student_name is the student's name, gender is their gender, and dept_id is the department ID associated with their declared major.

-- And the department table is described as below:

-- | Column Name | Type    |
-- |-------------|---------|
-- | dept_id     | Integer |
-- | dept_name   | String  |
-- where dept_id is the department's ID number and dept_name is the department name.

-- Here is an example input:
-- student table:

-- | student_id | student_name | gender | dept_id |
-- |------------|--------------|--------|---------|
-- | 1          | Jack         | M      | 1       |
-- | 2          | Jane         | F      | 1       |
-- | 3          | Mark         | M      | 2       |
-- department table:

-- | dept_id | dept_name   |
-- |---------|-------------|
-- | 1       | Engineering |
-- | 2       | Science     |
-- | 3       | Law         |
-- The Output should be:

-- | dept_name   | student_number |
-- |-------------|----------------|
-- | Engineering | 2              |
-- | Science     | 1              |
-- | Law         | 0              |

CREATE TABLE student (
	student_id INTEGER,
    student_name CHAR(100),
    gender CHAR(1),
    dept_id INTEGER
);

CREATE TABLE department (
  dept_id INTEGER,
  dept_name CHAR(100)
);

INSERT INTO student
  (student_id, student_name, gender, dept_id)
VALUES
('1','Jack','M','1'),
('2','Jane','F','1'),
('3','Mark','M','2');


INSERT INTO department
  (dept_id, dept_name)
VALUES
('1','Engineering'),
('2','Science'),
('3','Law');

SELECT dept_name, COALESCE(student_number,0)
FROM department AS d
LEFT JOIN (
SELECT dept_id, COUNT(student_id) AS student_number
FROM student 
GROUP BY dept_id) AS s
ON d.dept_id = s.dept_id;

-- Question 110: Countries you can safely invest in
-- Table Person:

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | id             | int     |
-- | name           | varchar |
-- | phone_number   | varchar |
-- +----------------+---------+
-- id is the primary key for this table.
-- Each row of this table contains the name of a person and their phone number.
-- Phone number will be in the form 'xxx-yyyyyyy' where xxx is the country code (3 characters) and yyyyyyy is the 
-- phone number (7 characters) where x and y are digits. Both can contain leading zeros.
-- Table Country:

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | name           | varchar |
-- | country_code   | varchar |
-- +----------------+---------+
-- country_code is the primary key for this table.
-- Each row of this table contains the country name and its code. country_code will be in the form 'xxx' where x is digits.
 

-- Table Calls:

-- +-------------+------+
-- | Column Name | Type |
-- +-------------+------+
-- | caller_id   | int  |
-- | callee_id   | int  |
-- | duration    | int  |
-- +-------------+------+
-- There is no primary key for this table, it may contain duplicates.
-- Each row of this table contains the caller id, callee id and the duration of the call in minutes. caller_id != callee_id
-- A telecommunications company wants to invest in new countries. The country intends to invest in the countries where the average call duration of the calls in this country is strictly greater than the global average call duration.

-- Write an SQL query to find the countries where this company can invest.

-- Return the result table in any order.

-- The query result format is in the following example.

-- Person table:
-- +----+----------+--------------+
-- | id | name     | phone_number |
-- +----+----------+--------------+
-- | 3  | Jonathan | 051-1234567  |
-- | 12 | Elvis    | 051-7654321  |
-- | 1  | Moncef   | 212-1234567  |
-- | 2  | Maroua   | 212-6523651  |
-- | 7  | Meir     | 972-1234567  |
-- | 9  | Rachel   | 972-0011100  |
-- +----+----------+--------------+

-- Country table:
-- +----------+--------------+
-- | name     | country_code |
-- +----------+--------------+
-- | Peru     | 051          |
-- | Israel   | 972          |
-- | Morocco  | 212          |
-- | Germany  | 049          |
-- | Ethiopia | 251          |
-- +----------+--------------+

-- Calls table:
-- +-----------+-----------+----------+
-- | caller_id | callee_id | duration |
-- +-----------+-----------+----------+
-- | 1         | 9         | 33       |
-- | 2         | 9         | 4        |
-- | 1         | 2         | 59       |
-- | 3         | 12        | 102      |
-- | 3         | 12        | 330      |
-- | 12        | 3         | 5        |
-- | 7         | 9         | 13       |
-- | 7         | 1         | 3        |
-- | 9         | 7         | 1        |
-- | 1         | 7         | 7        |
-- +-----------+-----------+----------+

-- Result table:
-- +----------+
-- | country  |
-- +----------+
-- | Peru     |
-- +----------+
-- The average call duration for Peru is (102 + 102 + 330 + 330 + 5 + 5) / 6 = 145.666667
-- The average call duration for Israel is (33 + 4 + 13 + 13 + 3 + 1 + 1 + 7) / 8 = 9.37500
-- The average call duration for Morocco is (33 + 4 + 59 + 59 + 3 + 7) / 6 = 27.5000 
-- Global call duration average = (2 * (33 + 3 + 59 + 102 + 330 + 5 + 13 + 3 + 1 + 7)) / 20 = 55.70000
-- Since Peru is the only country where average call duration is greater than the global average, it's the only recommended country.

CREATE TABLE Person (
	id INTEGER,
    name VARCHAR(100),
    phone_number VARCHAR(100)
);

CREATE TABLE Country (
  name VARCHAR(100),
  country_code CHAR(100)
);

CREATE TABLE Calls (
  caller_id INTEGER,
  callee_id INTEGER,
  duration INTEGER
);

INSERT INTO Person
  (id, name, phone_number)
VALUES
('3','Jonathan','051-1234567'),
('12','Elvis','051-7654321'),
('1','Moncef','212-1234567'),
('2','Maroua','212-6523651'),
('7','Meir','972-1234567'),
('9','Rachel','972-0011100');

INSERT INTO Country
  (name, country_code)
VALUES
('Peru','051'),
('Israel','972'),
('Morocco','212'),
('Germany','049'),
('Ethiopia','251');

INSERT INTO Calls
  (caller_id, callee_id, duration)
VALUES
('1','9','33'),
('2','9','4'),
('1','2','59'),
('3','12','102'),
('3','12','330'),
('12','3','5'),
('7','9','13'),
('7','1','3'),
('9','7','1'),
('1','7','7');

WITH Caller AS (
(SELECT caller_id AS id, duration FROM Calls)
UNION
(Select callee_id AS id, duration FROM Calls)
),

Person_Country AS (
SELECT p.*, c.name AS country_name
FROM (SELECT *, LEFT(TRIM(phone_number),3) AS country_code FROM Person) AS p
LEFT JOIN Country AS c
ON p.country_code = c.country_code)

SELECT country_name FROM Caller AS c
LEFT JOIN Person_Country AS p
ON c.id = p.id
GROUP BY country_name
HAVING AVG(duration) > (SELECT AVG(duration) FROM Caller);

-- Question 72: Customers who bought a, b but not c
-- Table: Customers

-- +---------------------+---------+
-- | Column Name         | Type    |
-- +---------------------+---------+
-- | customer_id         | int     |
-- | customer_name       | varchar |
-- +---------------------+---------+
-- customer_id is the primary key for this table.
-- customer_name is the name of the customer.
 
-- Table: Orders

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | order_id      | int     |
-- | customer_id   | int     |
-- | product_name  | varchar |
-- +---------------+---------+
-- order_id is the primary key for this table.
-- customer_id is the id of the customer who bought the product "product_name".
 

-- Write an SQL query to report the customer_id and customer_name of customers who bought products "A", "B" but did not buy the product "C" since we want to recommend them buy this product.

-- Return the result table ordered by customer_id.

-- The query result format is in the following example.

-- Customers table:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- | 1           | Daniel        |
-- | 2           | Diana         |
-- | 3           | Elizabeth     |
-- | 4           | Jhon          |
-- +-------------+---------------+

-- Orders table:
-- +------------+--------------+---------------+
-- | order_id   | customer_id  | product_name  |
-- +------------+--------------+---------------+
-- | 10         |     1        |     A         |
-- | 20         |     1        |     B         |
-- | 30         |     1        |     D         |
-- | 40         |     1        |     C         |
-- | 50         |     2        |     A         |
-- | 60         |     3        |     A         |
-- | 70         |     3        |     B         |
-- | 80         |     3        |     D         |
-- | 90         |     4        |     C         |
-- +------------+--------------+---------------+

-- Result table:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- | 3           | Elizabeth     |
-- +-------------+---------------+
-- Only the customer_id with id 3 bought the product A and B but not the product C.

CREATE TABLE Customers (
  customer_id INTEGER,
  customer_name VARCHAR(100)
);

CREATE TABLE Orders (
  order_id INTEGER,
  customer_id INTEGER,
  product_name VARCHAR(100)
);

INSERT INTO Customers
  (customer_id, customer_name)
VALUES
('1','Daniel'),
('2','Diana'),
('3','Elizabeth'),
('4','Jhon');   

INSERT INTO Orders
  (order_id, customer_id, product_name)
VALUES
('10','1','A'),
('20','1','B'),
('30','1','D'),
('40','1','C'),
('50','2','A'),
('60','3','A'),
('70','3','B'),
('80','3','D'),
('90','4','C');  

WITH combine AS (
SELECT x.*, a.product_name AS pdt_A, b.product_name AS pdt_B, c.product_name AS pdt_C
FROM Customers AS x
LEFT JOIN (SELECT * FROM Orders WHERE product_name = 'A') AS a
ON x.customer_id = a.customer_id
LEFT JOIN (SELECT * FROM Orders WHERE product_name = 'B') AS b
ON x.customer_id = b.customer_id
LEFT JOIN (SELECT * FROM Orders WHERE product_name = 'C') AS c
ON x.customer_id = c.customer_id)

SELECT customer_id, customer_name
FROM combine
WHERE pdt_a IS NOT NULL and pdt_b IS NOT NULL and pdt_c IS NULL;

-- Question 93: Customers who bought all products
-- Table: Customer

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | customer_id | int     |
-- | product_key | int     |
-- +-------------+---------+
-- product_key is a foreign key to Product table.
-- Table: Product

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | product_key | int     |
-- +-------------+---------+
-- product_key is the primary key column for this table.
 

-- Write an SQL query for a report that provides the customer ids from the Customer table that bought all the products in the Product table.

-- For example:

-- Customer table:
-- +-------------+-------------+
-- | customer_id | product_key |
-- +-------------+-------------+
-- | 1           | 5           |
-- | 2           | 6           |
-- | 3           | 5           |
-- | 3           | 6           |
-- | 1           | 6           |
-- +-------------+-------------+

-- Product table:
-- +-------------+
-- | product_key |
-- +-------------+
-- | 5           |
-- | 6           |
-- +-------------+

-- Result table:
-- +-------------+
-- | customer_id |
-- +-------------+
-- | 1           |
-- | 3           |
-- +-------------+
-- The customers who bought all the products (5 and 6) are customers with id 1 and 3.

CREATE TABLE Customer (
  customer_id INTEGER,
  product_key INTEGER
);

CREATE TABLE Product (
  product_key INTEGER
);

INSERT INTO Customer
  (customer_id, product_key)
VALUES
('1','5'),
('2','6'),
('3','5'),
('3','6'),
('1','6');

INSERT INTO Product
  (product_key)
VALUES
('5'),
('6');

SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = 
(SELECT COUNT(DISTINCT product_key) FROM Product);


-- Question 57: Department Highest Salary
-- The Employee table holds all employees. Every employee has an Id, a salary, and there is also a column for the department Id.

-- +----+-------+--------+--------------+
-- | Id | Name  | Salary | DepartmentId |
-- +----+-------+--------+--------------+
-- | 1  | Joe   | 70000  | 1            |
-- | 2  | Jim   | 90000  | 1            |
-- | 3  | Henry | 80000  | 2            |
-- | 4  | Sam   | 60000  | 2            |
-- | 5  | Max   | 90000  | 1            |
-- +----+-------+--------+--------------+
-- The Department table holds all departments of the company.

-- +----+----------+
-- | Id | Name     |
-- +----+----------+
-- | 1  | IT       |
-- | 2  | Sales    |
-- +----+----------+
-- Write a SQL query to find employees who have the highest salary in each of the departments. 
-- For the above tables, your SQL query should return the following rows (order of rows does not matter).

-- +------------+----------+--------+
-- | Department | Employee | Salary |
-- +------------+----------+--------+
-- | IT         | Max      | 90000  |
-- | IT         | Jim      | 90000  |
-- | Sales      | Henry    | 80000  |
-- +------------+----------+--------+
-- Explanation:

-- Max and Jim both have the highest salary in the IT department and Henry has the highest salary in the Sales department.

CREATE TABLE Employee (
  Id INTEGER,
  Name VARCHAR(100),
  Salary VARCHAR(100),
  DepartmentID INTEGER
);

CREATE TABLE Department (
  Id INTEGER,
  Name VARCHAR(100)
);

INSERT INTO Employee
  (Id, Name, Salary, DepartmentID)
VALUES
('1','Joe','70000','1'),
('2','Jim','90000','1'),
('3','Henry','80000','2'),
('4','Sam','60000','2'),
('5','Max','90000','1');

INSERT INTO Department
  (Id, Name)
VALUES
('1','IT'),
('2','Sales');

SELECT d.Name as Department, e.Name as Employee, e.Salary
FROM Employee AS e
LEFT JOIN (
SELECT DepartmentId, MAX(Salary) AS Max_Salary
FROM Employee
GROUP BY DepartmentID) as subquery
ON e.DepartmentID = subquery.DepartmentID
LEFT JOIN Department as d
ON e.DepartmentID = d.Id
WHERE Salary = Max_Salary;

-- Question 78: Evaluate Boolean Expressions
-- Table Variables:

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | name          | varchar |
-- | value         | int     |
-- +---------------+---------+
-- name is the primary key for this table.
-- This table contains the stored variables and their values.

-- Table Expressions:

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | left_operand  | varchar |
-- | operator      | enum    |
-- | right_operand | varchar |
-- +---------------+---------+
-- (left_operand, operator, right_operand) is the primary key for this table.
-- This table contains a boolean expression that should be evaluated.
-- operator is an enum that takes one of the values ('<', '>', '=')
-- The values of left_operand and right_operand are guaranteed to be in the Variables table.
 
-- Write an SQL query to evaluate the boolean expressions in Expressions table.

-- Return the result table in any order.

-- The query result format is in the following example.

-- Variables table:
-- +------+-------+
-- | name | value |
-- +------+-------+
-- | x    | 66    |
-- | y    | 77    |
-- +------+-------+

-- Expressions table:
-- +--------------+----------+---------------+
-- | left_operand | operator | right_operand |
-- +--------------+----------+---------------+
-- | x            | >        | y             |
-- | x            | <        | y             |
-- | x            | =        | y             |
-- | y            | >        | x             |
-- | y            | <        | x             |
-- | x            | =        | x             |
-- +--------------+----------+---------------+

-- Result table:
-- +--------------+----------+---------------+-------+
-- | left_operand | operator | right_operand | value |
-- +--------------+----------+---------------+-------+
-- | x            | >        | y             | false |
-- | x            | <        | y             | true  |
-- | x            | =        | y             | false |
-- | y            | >        | x             | true  |
-- | y            | <        | x             | false |
-- | x            | =        | x             | true  |
-- +--------------+----------+---------------+-------+
-- As shown, you need find the value of each boolean exprssion in the table using the variables table.

CREATE TABLE Variables (
  name VARCHAR(100),
  value INTEGER
);

CREATE TYPE operator AS ENUM('<','>','=');

CREATE TABLE Expressions (
  left_operand VARCHAR(50),
  operator operator,
  right_operand VARCHAR(50)
);

INSERT INTO Variables
  (name,value)
VALUES
('x','66'),
('y','77');

INSERT INTO Expressions 
  (left_operand,operator,right_operand)
VALUES
('x','>','y'),
('x','<','y'),
('x','=','y'),
('y','>','x'),
('y','<','x'),
('x','=','x'); 

WITH Combine_Table AS (
SELECT e.*, l.value AS Left_Value, r.value AS Right_Value
FROM Expressions AS e
LEFT JOIN Variables AS l
ON e.left_operand = l.name
LEFT JOIN Variables AS r
ON e.left_operand = r.name)

SELECT left_operand,operator,right_operand,
CASE WHEN operator='<' THEN (SELECT left_value < right_value)
	      WHEN operator='>' THEN (SELECT left_value > right_value)
          WHEN operator='=' THEN (SELECT left_value = right_value) ELSE False END AS value
FROM Combine_Table;

-- Question 56
-- Mary is a teacher in a middle school and she has a table seat storing students' names and their corresponding seat ids.
-- The column id is continuous increment.
-- Mary wants to change seats for the adjacent students.
-- Can you write a SQL query to output the result for Mary?

-- +---------+---------+
-- |    id   | student |
-- +---------+---------+
-- |    1    | Abbot   |
-- |    2    | Doris   |
-- |    3    | Emerson |
-- |    4    | Green   |
-- |    5    | Jeames  |
-- +---------+---------+
-- For the sample input, the output is:
 

-- +---------+---------+
-- |    id   | student |
-- +---------+---------+
-- |    1    | Doris   |
-- |    2    | Abbot   |
-- |    3    | Green   |
-- |    4    | Emerson |
-- |    5    | Jeames  |
-- +---------+---------+

...............................................

-- Question 80: Find the start and end number of continuous ranges
-- Table: Logs

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | log_id        | int     |
-- +---------------+---------+
-- id is the primary key for this table.
-- Each row of this table contains the ID in a log Table.

-- Since some IDs have been removed from Logs. Write an SQL query to find the start and end number of continuous ranges in table Logs.

-- Order the result table by start_id.

-- The query result format is in the following example:

-- Logs table:
-- +------------+
-- | log_id     |
-- +------------+
-- | 1          |
-- | 2          |
-- | 3          |
-- | 7          |
-- | 8          |
-- | 10         |
-- +------------+

-- Result table:
-- +------------+--------------+
-- | start_id   | end_id       |
-- +------------+--------------+
-- | 1          | 3            |
-- | 7          | 8            |
-- | 10         | 10           |
-- +------------+--------------+
-- The result table should contain all ranges in table Logs.
-- From 1 to 3 is contained in the table.
-- From 4 to 6 is missing in the table
-- From 7 to 8 is contained in the table.
-- Number 9 is missing in the table.
-- Number 10 is contained in the table.

......................

-- Question 60: Friend Requests
-- In social network like Facebook or Twitter, people send friend requests and accept others' requests as well.

-- Table request_accepted

-- +--------------+-------------+------------+
-- | requester_id | accepter_id | accept_date|
-- |--------------|-------------|------------|
-- | 1            | 2           | 2016_06-03 |
-- | 1            | 3           | 2016-06-08 |
-- | 2            | 3           | 2016-06-08 |
-- | 3            | 4           | 2016-06-09 |
-- +--------------+-------------+------------+
-- This table holds the data of friend acceptance, while requester_id and accepter_id both are the id of a person.
 

-- Write a query to find the the people who has most friends and the most friends number under the following rules:

-- It is guaranteed there is only 1 people having the most friends.
-- The friend request could only been accepted once, which mean there is no multiple records with the same requester_id and accepter_id value.
-- For the sample data above, the result is:

-- Result table:
-- +------+------+
-- | id   | num  |
-- |------|------|
-- | 3    | 3    |
-- +------+------+
-- The person with id '3' is a friend of people '1', '2' and '4', so he has 3 friends in total, which is the most number than any others.

............................

-- Question 62: Game Play Analysis 3
-- Table: Activity

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | player_id    | int     |
-- | device_id    | int     |
-- | event_date   | date    |
-- | games_played | int     |
-- +--------------+---------+
-- (player_id, event_date) is the primary key of this table.
-- This table shows the activity of players of some game.
-- Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on some day using some device.
 
-- Write an SQL query that reports for each player and date, how many games played so far by the player. That is, the total number of games played by the player until that date. Check the example for clarity.

-- The query result format is in the following example:

-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-05-02 | 6            |
-- | 1         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-02 | 0            |
-- | 3         | 4         | 2018-07-03 | 5            |
-- +-----------+-----------+------------+--------------+

-- Result table:
-- +-----------+------------+---------------------+
-- | player_id | event_date | games_played_so_far |
-- +-----------+------------+---------------------+
-- | 1         | 2016-03-01 | 5                   |
-- | 1         | 2016-05-02 | 11                  |
-- | 1         | 2017-06-25 | 12                  |
-- | 3         | 2016-03-02 | 0                   |
-- | 3         | 2018-07-03 | 5                   |
-- +-----------+------------+---------------------+
-- For the player with id 1, 5 + 6 = 11 games played by 2016-05-02, and 5 + 6 + 1 = 12 games played by 2017-06-25.
-- For the player with id 3, 0 + 5 = 5 games played by 2018-07-03.
-- Note that for each player we only care about the days when the player logged in.

CREATE TABLE Activity (
  player_id INTEGER,
  device_id INTEGER,
  event_date DATE,
  games_played INTEGER
);

INSERT INTO Activity 
  (player_id, device_id, event_date, games_played)
VALUES
('1','2','2016-03-01','5'),
('1','2','2016-05-02','6'),
('1','3','2017-06-25','1'),
('3','1','2016-03-02','0'),
('3','4','2018-07-03','5');

SELECT player_id, event_date, SUM(games_played) OVER (PARTITION BY player_id ORDER BY event_date) as games_played_so_far
FROM activity
ORDER BY player_id, event_date;

-- Question 91: Game Play Analysis 4
-- Table: Activity

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | player_id    | int     |
-- | device_id    | int     |
-- | event_date   | date    |
-- | games_played | int     |
-- +--------------+---------+
-- (player_id, event_date) is the primary key of this table.
-- This table shows the activity of players of some game.
-- Each row is a record of a player who logged in and played a number of games (possibly 0) 
-- before logging out on some day using some device.
 

-- Write an SQL query that reports the fraction of players that logged in again 
-- on the day after the day they first logged in, rounded to 2 decimal places. 
-- In other words, you need to count the number of players that logged in for at least two consecutive 
-- days starting from their first login date, then divide that number by the total number of players.

-- The query result format is in the following example:

-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-03-02 | 6            |
-- | 2         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-02 | 0            |
-- | 3         | 4         | 2018-07-03 | 5            |
-- +-----------+-----------+------------+--------------+

-- Result table:
-- +-----------+
-- | fraction  |
-- +-----------+
-- | 0.33      |
-- +-----------+
-- Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33

CREATE TABLE Activity (
  player_id INTEGER,
  device_id INTEGER,
  event_date DATE,
  games_played INTEGER
);

INSERT INTO Activity 
  (player_id, device_id, event_date, games_played)
VALUES
('1','2','2016-03-01','5'),
('1','2','2016-05-02','6'),
('2','3','2017-06-25','1'),
('3','1','2016-03-02','0'),
('3','4','2018-07-03','5');

WITH min_Activity AS (
SELECT *, MIN(event_date) OVER (PARTITION BY player_id) AS min_event_date
FROM Activity),
    days AS (
SELECT player_id, device_id, CASE WHEN event_date - min_event_date <365 and event_date - min_event_date > 0 THEN player_id ELSE NULL END AS flag
FROM min_Activity)

SELECT ROUND(COUNT(DISTINCT flag)::NUMERIC/COUNT(DISTINCT player_id),2) AS fraction FROM days;


-- Question 86: Get highest answer rate question
-- Get the highest answer rate question from a table survey_log with these columns: id, action, question_id, answer_id, q_num, timestamp.

-- id means user id; action has these kind of values: "show", "answer", "skip"; answer_id is not null when action column is "answer", 
-- hile is null for "show" and "skip"; q_num is the numeral order of the question in current session.

-- Write a sql query to identify the question which has the highest answer rate.

-- Example:

-- Input:
-- +------+-----------+--------------+------------+-----------+------------+
-- | id   | action    | question_id  | answer_id  | q_num     | timestamp  |
-- +------+-----------+--------------+------------+-----------+------------+
-- | 5    | show      | 285          | null       | 1         | 123        |
-- | 5    | answer    | 285          | 124124     | 1         | 124        |
-- | 5    | show      | 369          | null       | 2         | 125        |
-- | 5    | skip      | 369          | null       | 2         | 126        |
-- +------+-----------+--------------+------------+-----------+------------+
-- Output:
-- +-------------+
-- | survey_log  |
-- +-------------+
-- |    285      
-- +-------------+
-- Explanation:
-- question 285 has answer rate 1/1, while question 369 has 0/1 answer rate, so output 285.
-- Note: The highest answer rate meaning is: answer number's ratio in show number in the same question.

CREATE TYPE action AS ENUM('show', 'answer', 'skip');

CREATE TABLE survey_log (
  id INTEGER,
  action action,
  question_id INTEGER,
  answer_id INTEGER,
  q_num INTEGER,
  timestamp INTEGER
);

INSERT INTO survey_log
  (id, action, question_id, answer_id, q_num, timestamp)
VALUES
('5','show','285','null','1','123'),
('5','answer','285','124124','1','124'),
('5','show','369','null','2','125'),
('5','skip','369','null','2','126');

...................................................

-- Question 82: Immediate Food Delivery 2
-- Table: Delivery

-- +-----------------------------+---------+
-- | Column Name                 | Type    |
-- +-----------------------------+---------+
-- | delivery_id                 | int     |
-- | customer_id                 | int     |
-- | order_date                  | date    |
-- | customer_pref_delivery_date | date    |
-- +-----------------------------+---------+
-- delivery_id is the primary key of this table.
-- The table holds information about food delivery to customers that make orders at some date and specify a preferred delivery date (on the same order date or after it).
 
-- If the preferred delivery date of the customer is the same as the order date then the order is called immediate otherwise it's called scheduled.
-- The first order of a customer is the order with the earliest order date that customer made. It is guaranteed that a customer has exactly one first order.
-- Write an SQL query to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.
-- The query result format is in the following example:

-- Delivery table:
-- +-------------+-------------+------------+-----------------------------+
-- | delivery_id | customer_id | order_date | customer_pref_delivery_date |
-- +-------------+-------------+------------+-----------------------------+
-- | 1           | 1           | 2019-08-01 | 2019-08-02                  |
-- | 2           | 2           | 2019-08-02 | 2019-08-02                  |
-- | 3           | 1           | 2019-08-11 | 2019-08-12                  |
-- | 4           | 3           | 2019-08-24 | 2019-08-24                  |
-- | 5           | 3           | 2019-08-21 | 2019-08-22                  |
-- | 6           | 2           | 2019-08-11 | 2019-08-13                  |
-- | 7           | 4           | 2019-08-09 | 2019-08-09                  |
-- +-------------+-------------+------------+-----------------------------+

-- Result table:
-- +----------------------+
-- | immediate_percentage |
-- +----------------------+
-- | 50.00                |
-- +----------------------+
-- The customer id 1 has a first order with delivery id 1 and it is scheduled.
-- The customer id 2 has a first order with delivery id 2 and it is immediate.
-- The customer id 3 has a first order with delivery id 5 and it is scheduled.
-- The customer id 4 has a first order with delivery id 7 and it is immediate.
-- Hence, half the customers have immediate first orders.

CREATE TABLE Delivery (
  delivery_id INTEGER,
  customer_id INTEGER,
  order_date DATE,
  customer_pref_delivery_date DATE
);

INSERT INTO Delivery
  (delivery_id, customer_id, order_date, customer_pref_delivery_date)
VALUES
('1','1','2019-08-01','2019-08-02'),
('2','2','2019-08-02','2019-08-02'),
('3','1','2019-08-11','2019-08-12'),
('4','3','2019-08-24','2019-08-24'),
('5','3','2019-08-21','2019-08-22'),
('6','2','2019-08-11','2019-08-13'),
('7','4','2019-08-09','2019-08-09');

WITH Delivery_Immed AS (
SELECT *, CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE NULL END AS immed,
  MIN(order_date) OVER(PARTITION BY customer_id ORDER BY customer_id, order_date ASC) AS min_order_date
FROM Delivery)

SELECT ROUND(SUM(immed)::NUMERIC/COUNT(DISTINCT customer_id)*100,2) AS immediate_percentage
FROM Delivery_Immed
WHERE order_date = min_order_date;

-- Question 96: Investments in 2016
-- Write a query to print the sum of all total investment values in 2016 (TIV_2016), to a scale of 2 decimal places, for all policy holders who meet the following criteria:

-- Have the same TIV_2015 value as one or more other policyholders.
-- Are not located in the same city as any other policyholder (i.e.: the (latitude, longitude) attribute pairs must be unique).
-- Input Format:
-- The insurance table is described as follows:

-- | Column Name | Type          |
-- |-------------|---------------|
-- | PID         | INTEGER(11)   |
-- | TIV_2015    | NUMERIC(15,2) |
-- | TIV_2016    | NUMERIC(15,2) |
-- | LAT         | NUMERIC(5,2)  |
-- | LON         | NUMERIC(5,2)  |
-- where PID is the policyholder's policy ID, TIV_2015 is the total investment value in 2015, TIV_2016 is the total investment value in 2016, LAT is the latitude of the policy holder's city, and LON is the longitude of the policy holder's city.

-- Sample Input

-- | PID | TIV_2015 | TIV_2016 | LAT | LON |
-- |-----|----------|----------|-----|-----|
-- | 1   | 10       | 5        | 10  | 10  |
-- | 2   | 20       | 20       | 20  | 20  |
-- | 3   | 10       | 30       | 20  | 20  |
-- | 4   | 10       | 40       | 40  | 40  |
-- Sample Output

-- | TIV_2016 |
-- |----------|
-- | 45.00    |
-- Explanation

-- The first record in the table, like the last record, meets both of the two criteria.
-- The TIV_2015 value '10' is as the same as the third and forth record, and its location unique.
-- The second record does not meet any of the two criteria. Its TIV_2015 is not like any other policyholders.
-- And its location is the same with the third record, which makes the third record fail, too.
-- So, the result is the sum of TIV_2016 of the first and last record, which is 45.

...................................................................................................................................

