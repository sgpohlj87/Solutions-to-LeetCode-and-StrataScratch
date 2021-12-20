/* SQL Leetcode Challenge - Hard*/

-- Question 108: Average Salary
-- Given two tables as below, write a query to display the comparison result (higher/lower/same) of the 
-- average salary of employees in a department to the company's average salary.
 
-- Table: salary
-- | id | employee_id | amount | pay_date   |
-- |----|-------------|--------|------------|
-- | 1  | 1           | 9000   | 2017-03-31 |
-- | 2  | 2           | 6000   | 2017-03-31 |
-- | 3  | 3           | 10000  | 2017-03-31 |
-- | 4  | 1           | 7000   | 2017-02-28 |
-- | 5  | 2           | 6000   | 2017-02-28 |
-- | 6  | 3           | 8000   | 2017-02-28 |
 
-- The employee_id column refers to the employee_id in the following table employee.

-- | employee_id | department_id |
-- |-------------|---------------|
-- | 1           | 1             |
-- | 2           | 2             |
-- | 3           | 2             |

-- So for the sample data above, the result is:
 
-- | pay_month | department_id | comparison  |
-- |-----------|---------------|-------------|
-- | 2017-03   | 1             | higher      |
-- | 2017-03   | 2             | lower       |
-- | 2017-02   | 1             | same        |
-- | 2017-02   | 2             | same        |
 
-- Explanation

-- In March, the company's average salary is (9000+6000+10000)/3 = 8333.33...
-- The average salary for department '1' is 9000, which is the salary of employee_id '1' since there is only one employee in this department. So the comparison result is 'higher' since 9000 > 8333.33 obviously.
-- The average salary of department '2' is (6000 + 10000)/2 = 8000, which is the average of employee_id '2' and '3'. So the comparison result is 'lower' since 8000 < 8333.33.
-- With he same formula for the average salary comparison in February, the result is 'same' since both the department '1' and '2' have the same average salary with the company, which is 7000.

CREATE TABLE salary (
	id INTEGER,
    employee_id INTEGER,
    amount INTEGER,
    pay_date DATE
);

CREATE TABLE employee (
  employee_id INTEGER,
  department_id INTEGER
);


INSERT INTO salary
  (id, employee_id, amount, pay_date)
VALUES
('1','1','9000','2017-03-31'),
('2','2','6000','2017-03-31'),
('3','3','10000','2017-03-31'),
('4','1','7000','2017-02-28'),
('5','2','6000','2017-02-28'),
('6','3','8000','2017-02-28');

INSERT INTO employee
  (employee_id, department_id)
VALUES
('1','1'),
('2','2'),
('3','2');

WITH month_average AS (
SELECT DATE(DATE_TRUNC('month',pay_date)) AS pay_month, AVG(amount) AS month_avg
FROM salary
GROUP BY pay_month)

SELECT d.pay_month, d.department_id, 
CASE WHEN dept_avg > month_avg THEN 'higher'
          WHEN dept_avg < month_avg  THEN 'lower'
          ELSE 'same' END AS comparison
FROM (
SELECT DATE(DATE_TRUNC('month',pay_date)) AS pay_month, department_id, AVG(amount) AS dept_avg
FROM (
SELECT s.*, department_id 
FROM salary AS s
LEFT JOIN employee as e
ON s.employee_id = e.employee_id) AS subquery
GROUP BY pay_month, department_id
ORDER BY AVG(amount) DESC) AS d
LEFT JOIN month_average AS m
ON d.pay_month = m.pay_month;

-- Question 102: Cumulative Salary
-- The Employee table holds the salary information in a year.

-- Write a SQL to get the cumulative sum of an employee's salary over a period of 3 months but exclude the most recent month.

-- The result should be displayed by 'Id' ascending, and then by 'Month' descending.

-- Example
-- Input

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 1  | 2     | 30     |
-- | 2  | 2     | 30     |
-- | 3  | 2     | 40     |
-- | 1  | 3     | 40     |
-- | 3  | 3     | 60     |
-- | 1  | 4     | 60     |
-- | 3  | 4     | 70     |
-- Output

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 3     | 90     |
-- | 1  | 2     | 50     |
-- | 1  | 1     | 20     |
-- | 2  | 1     | 20     |
-- | 3  | 3     | 100    |
-- | 3  | 2     | 40     |
 
-- Explanation
-- Employee '1' has 3 salary records for the following 3 months except the most recent month '4': salary 40 for month '3', 30 for month '2' and 20 for month '1'
-- So the cumulative sum of salary of this employee over 3 months is 90(40+30+20), 50(30+20) and 20 respectively.

-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 1  | 3     | 90     |
-- | 1  | 2     | 50     |
-- | 1  | 1     | 20     |
-- Employee '2' only has one salary record (month '1') except its most recent month '2'.
-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 2  | 1     | 20     |
 

-- Employ '3' has two salary records except its most recent pay month '4': month '3' with 60 and month '2' with 40. So the cumulative salary is as following.
-- | Id | Month | Salary |
-- |----|-------|--------|
-- | 3  | 3     | 100    |
-- | 3  | 2     | 40     |

....................................

-- Question 14: Department top three salaries
-- The Employee table holds all employees. Every employee has an Id, and there is also a column for the department Id.

-- +----+-------+--------+--------------+
-- | Id | Name  | Salary | DepartmentId |
-- +----+-------+--------+--------------+
-- | 1  | Joe   | 85000  | 1            |
-- | 2  | Henry | 80000  | 2            |
-- | 3  | Sam   | 60000  | 2            |
-- | 4  | Max   | 90000  | 1            |
-- | 5  | Janet | 69000  | 1            |
-- | 6  | Randy | 85000  | 1            |
-- | 7  | Will  | 70000  | 1            |
-- +----+-------+--------+--------------+
-- The Department table holds all departments of the company.

-- +----+----------+
-- | Id | Name     |
-- +----+----------+
-- | 1  | IT       |
-- | 2  | Sales    |
-- +----+----------+
-- Write a SQL query to find employees who earn the top three salaries in each of the department. For the above tables, your SQL query should return the following rows (order of rows does not matter).

-- +------------+----------+--------+
-- | Department | Employee | Salary |
-- +------------+----------+--------+
-- | IT         | Max      | 90000  |
-- | IT         | Randy    | 85000  |
-- | IT         | Joe      | 85000  |
-- | IT         | Will     | 70000  |
-- | Sales      | Henry    | 80000  |
-- | Sales      | Sam      | 60000  |
-- +------------+----------+--------+
-- Explanation:

-- In IT department, Max earns the highest salary, both Randy and Joe earn the second highest salary, 
-- and Will earns the third highest salary. 
-- There are only two employees in the Sales department, 
-- Henry earns the highest salary while Sam earns the second highest salary.
CREATE TABLE employee (
  Id INTEGER,
  Name VARCHAR(100),
  Salary INTEGER,
  DepartmentID INTEGER
);

CREATE TABLE department (
  Id INTEGER,
  Name VARCHAR(100)
);

INSERT INTO employee
  (Id, Name, Salary, DepartmentID)
VALUES
('1','Joe','85000','1'),
('2','Henry','80000','2'),
('3','Sam','60000','2'),
('4','Max','90000','1'),
('5','Janet','69000','1'),
('6','Randy','85000','1'),
('7','Will','70000','1');

INSERT INTO department
  (Id, Name)
VALUES
('1','IT'),
('2','Sales');

WITH Top3_salary AS (
SELECT DepartmentID,Salary
FROM (
SELECT *,
DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) as dense_rank
FROM employee) as subquery
WHERE dense_rank <=3
GROUP BY DepartmentID, Salary)

SELECT d.Name AS Department, e.Name AS Employee, e.Salary
FROM employee AS e
LEFT JOIN department AS d
ON e.DepartmentID = d.ID
RIGHT JOIN Top3_salary AS t
ON e.DepartmentID=t.DepartmentID AND e.Salary=t.Salary
GROUP BY d.Name, e.Name, e.Salary
ORDER BY d.Name,  e.Salary DESC;

-- Question 107: Find median given frequency of numbers
-- The Numbers table keeps the value of number and its frequency.

-- +----------+-------------+
-- |  Number  |  Frequency  |
-- +----------+-------------|
-- |  0       |  7          |
-- |  1       |  1          |
-- |  2       |  3          |
-- |  3       |  1          |
-- +----------+-------------+
-- In this table, the numbers are 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3, so the median is (0 + 0) / 2 = 0.

-- +--------+
-- | median |
-- +--------|
-- | 0.0000 |
-- +--------+
-- Write a query to find the median of all numbers and name the result as median.

.....................................................

-- Question 106: Find the quiet students in the exam
-- Table: Student

-- +---------------------+---------+
-- | Column Name         | Type    |
-- +---------------------+---------+
-- | student_id          | int     |
-- | student_name        | varchar |
-- +---------------------+---------+
-- student_id is the primary key for this table.
-- student_name is the name of the student.

-- Table: Exam

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | exam_id       | int     |
-- | student_id    | int     |
-- | score         | int     |
-- +---------------+---------+
-- (exam_id, student_id) is the primary key for this table.
-- Student with student_id got score points in exam with id exam_id.


-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score.
-- Write an SQL query to report the students (student_id, student_name) being "quiet" in ALL exams.
-- Don't return the student who has never taken any exam. Return the result table ordered by student_id.
-- The query result format is in the following example.

-- Student table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 1           | Daniel        |
-- | 2           | Jade          |
-- | 3           | Stella        |
-- | 4           | Jonathan      |
-- | 5           | Will          |
-- +-------------+---------------+

-- Exam table:
-- +------------+--------------+-----------+
-- | exam_id    | student_id   | score     |
-- +------------+--------------+-----------+
-- | 10         |     1        |    70     |
-- | 10         |     2        |    80     |
-- | 10         |     3        |    90     |
-- | 20         |     1        |    80     |
-- | 30         |     1        |    70     |
-- | 30         |     3        |    80     |
-- | 30         |     4        |    90     |
-- | 40         |     1        |    60     |
-- | 40         |     2        |    70     |
-- | 40         |     4        |    80     |
-- +------------+--------------+-----------+

-- Result table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 2           | Jade          |
-- +-------------+---------------+

-- For exam 1: Student 1 and 3 hold the lowest and high score respectively.
-- For exam 2: Student 1 hold both highest and lowest score.
-- For exam 3 and 4: Studnet 1 and 4 hold the lowest and high score respectively.
-- Student 2 and 5 have never got the highest or lowest in any of the exam.
-- Since student 5 is not taking any exam, he is excluded from the result.
-- So, we only return the information of Student 2.

CREATE TABLE student (
  student_id INTEGER,
  student_name VARCHAR(100)
);

CREATE TABLE exam (
  exam_id INTEGER,
  student_id INTEGER,
  score INTEGER
);

INSERT INTO student
  (student_id, student_name)
VALUES
('1','Daniel'),
('2','Jade'),
('3','Stella'),
('4','Jonathan'),
('5','Will');

INSERT INTO exam
  (exam_id, student_id, score)
VALUES
('10','1','70'),
('10','2','80'),
('10','3','90'),
('20','1','80'),
('30','1','70'),
('30','3','80'),
('30','4','90'),
('40','1','60'),
('40','2','70'),
('40','4','80');

WITH min_max_score AS (
SELECT MIN(score) AS min_score, MAX(score) AS max_score
FROM exam),
exam_min_max AS (
SELECT *, CONCAT(exam_id,student_id) AS id, CASE WHEN score > min_score and score < max_score THEN 1 ELSE 0 END AS flag
 FROM exam, min_max_score),
 rate AS (
 SELECT student_id, SUM(flag):: NUMERIC/COUNT(DISTINCT id) AS rate 
FROM exam_min_max
GROUP BY student_id)

SELECT s.*
FROM student AS s
LEFT JOIN rate AS r
ON s.student_id = r.student_id
WHERE rate=1;

-- Question 111: Game Play Analysis 5
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
 
-- We define the install date of a player to be the first login day of that player.
-- We also define day 1 retention of some date X to be the number of players whose install date is X and they logged back in on the day right after X, divided by the number of players whose install date is X, rounded to 2 decimal places.
-- Write an SQL query that reports for each install date, the number of players that installed the game on that day and the day 1 retention.

-- The query result format is in the following example:

-- Activity table:
-- +-----------+-----------+------------+--------------+
-- | player_id | device_id | event_date | games_played |
-- +-----------+-----------+------------+--------------+
-- | 1         | 2         | 2016-03-01 | 5            |
-- | 1         | 2         | 2016-03-02 | 6            |
-- | 2         | 3         | 2017-06-25 | 1            |
-- | 3         | 1         | 2016-03-01 | 0            |
-- | 3         | 4         | 2016-07-03 | 5            |
-- +-----------+-----------+------------+--------------+

-- Result table:
-- +------------+----------+----------------+
-- | install_dt | installs | Day1_retention |
-- +------------+----------+----------------+
-- | 2016-03-01 | 2        | 0.50           |
-- | 2017-06-25 | 1        | 0.00           |
-- +------------+----------+----------------+
-- Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the
-- day 1 retention of 2016-03-01 is 1 / 2 = 0.50
-- Player 2 installed the game on 2017-06-25 but didn't log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00

CREATE TABLE activity (
  player_id INTEGER,
  device_id INTEGER,
  event_date DATE,
  games_played INTEGER
);

INSERT INTO activity
  (player_id, device_id, event_date, games_played)
VALUES
('1','2','2016-03-01','5'),
('1','2','2016-03-02','6'),
('2','3','2017-06-25','1'),
('3','1','2016-03-01','0'),
('3','4','2016-07-03','5');

WITH dt_table AS (
SELECT *, CASE WHEN event_date - install_dt=1 THEN 1 ELSE 0 END AS retention, CASE WHEN event_date=install_dt THEN 1 ELSE 0 END AS install
FROM (
SELECT *, MIN(event_date) OVER (PARTITION BY player_id) AS install_dt
FROM activity) as subquery),
retention_install AS (
SELECT install_dt, SUM(retention) as retentions, SUM(install) AS installs
FROM dt_table
GROUP BY install_dt)

SELECT to_char(install_dt,'YYYY-MM-DD') AS install_dt, installs, ROUND(SUM(retentions)::NUMERIC/SUM(installs),2) AS Day1_retention
FROM retention_install
GROUP BY install_dt, installs
ORDER BY install_dt;

-- Question 99: Human traffic of stadium
-- X city built a new stadium, each day many people visit it and the stats are saved as these columns: id, visit_date, people

-- Please write a query to display the records which have 3 or more consecutive rows and the amount of people more than 100(inclusive).

-- For example, the table stadium:
-- +------+------------+-----------+
-- | id   | visit_date | people    |
-- +------+------------+-----------+
-- | 1    | 2017-01-01 | 10        |
-- | 2    | 2017-01-02 | 109       |
-- | 3    | 2017-01-03 | 150       |
-- | 4    | 2017-01-04 | 99        |
-- | 5    | 2017-01-05 | 145       |
-- | 6    | 2017-01-06 | 1455      |
-- | 7    | 2017-01-07 | 199       |
-- | 8    | 2017-01-08 | 188       |
-- +------+------------+-----------+
-- For the sample data above, the output is:

-- +------+------------+-----------+
-- | id   | visit_date | people    |
-- +------+------------+-----------+
-- | 5    | 2017-01-05 | 145       |
-- | 6    | 2017-01-06 | 1455      |
-- | 7    | 2017-01-07 | 199       |
-- | 8    | 2017-01-08 | 188       |
-- +------+------------+-----------+
-- Note:
-- Each day only have one row record, and the dates are increasing with id increasing.

CREATE TABLE stadium (
  id INTEGER,
  visit_date DATE,
  people INTEGER
);

INSERT INTO activity
  (id, visit_date, people)
VALUES
('1','2017-01-01','10'),
('2','2017-01-02','109'),
('3','2017-01-03','150'),
('4','2017-01-04','99'),
('5','2017-01-05','145'),
('6','2017-01-06','1455'),
('7','2017-01-07','199'),
('8','2017-01-08','188');

........................................................................... 

-- Question 103: Market Analysis 2
-- Table: Users

-- +----------------+---------+
-- | Column Name    | Type    |
-- +----------------+---------+
-- | user_id        | int     |
-- | join_date      | date    |
-- | favorite_brand | varchar |
-- +----------------+---------+
-- user_id is the primary key of this table.
-- This table has the info of the users of an online shopping website where users can sell and buy items.
-- Table: Orders

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | order_id      | int     |
-- | order_date    | date    |
-- | item_id       | int     |
-- | buyer_id      | int     |
-- | seller_id     | int     |
-- +---------------+---------+
-- order_id is the primary key of this table.
-- item_id is a foreign key to the Items table.
-- buyer_id and seller_id are foreign keys to the Users table.
-- Table: Items

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | item_id       | int     |
-- | item_brand    | varchar |
-- +---------------+---------+
-- item_id is the primary key of this table.
 
-- Write an SQL query to find for each user, whether the brand of the second item (by date) they sold is their favorite brand. 
-- If a user sold less than two items, report the answer for that user as no.
-- It is guaranteed that no seller sold more than one item on
-- The query result format is in the following example:

-- Users table:
-- +---------+------------+----------------+
-- | user_id | join_date  | favorite_brand |
-- +---------+------------+----------------+
-- | 1       | 2019-01-01 | Lenovo         |
-- | 2       | 2019-02-09 | Samsung        |
-- | 3       | 2019-01-19 | LG             |
-- | 4       | 2019-05-21 | HP             |
-- +---------+------------+----------------+

-- Orders table:
-- +----------+------------+---------+----------+-----------+
-- | order_id | order_date | item_id | buyer_id | seller_id |
-- +----------+------------+---------+----------+-----------+
-- | 1        | 2019-08-01 | 4       | 1        | 2         |
-- | 2        | 2019-08-02 | 2       | 1        | 3         |
-- | 3        | 2019-08-03 | 3       | 2        | 3         |
-- | 4        | 2019-08-04 | 1       | 4        | 2         |
-- | 5        | 2019-08-04 | 1       | 3        | 4         |
-- | 6        | 2019-08-05 | 2       | 2        | 4         |
-- +----------+------------+---------+----------+-----------+

-- Items table:
-- +---------+------------+
-- | item_id | item_brand |
-- +---------+------------+
-- | 1       | Samsung    |
-- | 2       | Lenovo     |
-- | 3       | LG         |
-- | 4       | HP         |
-- +---------+------------+

-- Result table:
-- +-----------+--------------------+
-- | seller_id | 2nd_item_fav_brand |
-- +-----------+--------------------+
-- | 1         | no                 |
-- | 2         | yes                |
-- | 3         | yes                |
-- | 4         | no                 |
-- +-----------+--------------------+

-- The answer for the user with id 1 is no because they sold nothing.
-- The answer for the users with id 2 and 3 is yes because the brands of their second sold items are their favorite brands.
-- The answer for the user with id 4 is no because the brand of their second sold item is not their favorite brand.

CREATE TABLE Users (
  user_id INTEGER,
  join_date DATE,
  favourite_brand VARCHAR(100)
);

CREATE TABLE Orders (
  order_id INTEGER,
  order_date DATE,
  item_id INTEGER,
  buyer_id INTEGER,
  seller_id INTEGER
);

CREATE TABLE Items (
  item_id INTEGER,
 item_brand VARCHAR(100)
);

INSERT INTO Users
  (user_id, join_date, favourite_brand)
VALUES
('1','2019-01-01','Lenovo'),
('2','2019-02-09','Samsung'),
('3','2019-01-19','LG'),
('4','2019-05-21','HP');

INSERT INTO Orders
  (order_id, order_date, item_id, buyer_id, seller_id)
VALUES
('1','2019-08-01','4','1','2'),
('2','2019-08-02','2','1','3'),
('3','2019-08-03','3','2','3'),
('4','2019-08-04','1','4','2'),
('5','2019-08-04','1','3','4'),
('6','2019-08-05','2','2','4');

INSERT INTO Items
  (item_id, item_brand)
VALUES
('1','Samsung'),
('2','Lenovo'),
('3','LG'),
('4','HP');

WITH check_data AS (
SELECT seller_id, CASE WHEN favourite_brand= item_brand THEN 'yes' ELSE 'no' END AS second_item_fav_brand
FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY order_date) as rn
FROM Orders) AS s
LEFT JOIN Users AS u
ON s.seller_id = u.user_id
LEFT JOIN Items AS i
ON s.item_id = i.item_id
WHERE rn=2)

SELECT u.user_id, CASE WHEN second_item_fav_brand IS NULL THEN 'no' ELSE second_item_fav_brand END AS second_item_fav_brand
FROM Users AS u
LEFT JOIN check_data AS c
ON u.user_id = c.seller_id;

-- Question 105: Median Employee Salary
-- The Employee table holds all employees. The employee table has three columns: Employee Id, Company Name, and Salary.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |1    | A          | 2341   |
-- |2    | A          | 341    |
-- |3    | A          | 15     |
-- |4    | A          | 15314  |
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |7    | B          | 15     |
-- |8    | B          | 13     |
-- |9    | B          | 1154   |
-- |10   | B          | 1345   |
-- |11   | B          | 1221   |
-- |12   | B          | 234    |
-- |13   | C          | 2345   |
-- |14   | C          | 2645   |
-- |15   | C          | 2645   |
-- |16   | C          | 2652   |
-- |17   | C          | 65     |
-- +-----+------------+--------+
-- Write a SQL query to find the median salary of each company. Bonus points if you can solve it without using any built-in SQL functions.

-- +-----+------------+--------+
-- |Id   | Company    | Salary |
-- +-----+------------+--------+
-- |5    | A          | 451    |
-- |6    | A          | 513    |
-- |12   | B          | 234    |
-- |9    | B          | 1154   |
-- |14   | C          | 2645   |
-- +-----+------------+--------+

...............................................................................

