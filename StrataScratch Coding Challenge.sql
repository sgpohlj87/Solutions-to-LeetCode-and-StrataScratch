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