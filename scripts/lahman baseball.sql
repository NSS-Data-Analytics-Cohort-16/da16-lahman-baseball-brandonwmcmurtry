-- **Directions:**  
-- * Within your repository, create a directory named "scripts" which will hold your scripts.
-- * Create a branch to hold your work.
-- * For each question, write a query to answer.
-- * Complete the initial ten questions before working on the open-ended ones.

-- **Initial Questions**

-- 1. What range of years for baseball games played does the provided database cover? 

SELECT 
MIN(yearid),
MAX(yearid)
FROM teams
--Answer: 1871-2016
SELECT *
FROM people


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
First name - people
last name - people 
height - people
number of games - appearances
team - appearances

SELECT
    p.namefirst AS first_name,
    p.namelast AS last_name,
    p.height,
    (
        SELECT a.g_all
        FROM appearances a
        WHERE a.playerid = p.playerid
    ) AS games_played,
    (
        SELECT a.teamid
        FROM appearances a
        WHERE a.playerid = p.playerid
    ) AS team
FROM people p
ORDER BY p.height ASC
LIMIT 1

---Answer: Eddie Gaedel, 43 inches, SLA

-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT *
FROM collegeplaying

SELECT c.playerid,
		c.schoolid,
		SUM (s.salary) AS total_salary
FROM collegeplaying AS c
	LEFT JOIN salaries AS s
	ON c.playerid = s.playerid
WHERE c.schoolid = 'vandy'
GROUP BY C.playerid, c.schoolid
HAVING SUM(s.salary) IS NOT NULL
ORDER BY total_salary DESC


---Answer: David Price

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT *
FROM fielding

SELECT
    CASE
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
        ELSE 'None'
    END AS position_group,
    SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY
    CASE
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
        ELSE 'None'
    END
ORDER BY total_putouts DESC

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT *
FROM teams
   
SELECT 
yearid/10*10 AS decade,
ROUND (SUM(SO) / SUM(g),2)AS avg_strikeout,
ROUND (SUM(hr) / SUM(g),2)AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade
----------
SELECT 
yearid/10*10 AS decade,
ROUND (SUM(so)::NUMERIC/SUM(g)::NUMERIC,2) AS avg_strikeouts,
ROUND (SUM(HR)::NUMERIC/SUM(g)::NUMERIC,2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade
   
--- Answer: The over all trend is that strikeouts tend to increase by decade as do homeruns as an over all trend. 


-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT *
FROM batting
-----------------
SELECT playerid, yearid, stolen_base_attempts,
ROUND(stolen_bases*1.0 / stolen_base_attempts,2) AS success_rate
FROM (
SELECT
playerid,yearid,
sb+cs AS stolen_base_attempts,sb AS stolen_bases
FROM batting
WHERE yearid = 2016) AS t
WHERE stolen_base_attempts > 20
ORDER BY success_rate DESC
LIMIT 1

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT *
FROM teams
-------TEAMS WITH MOST WINS, NO WS----
SELECT teamid, yearid, w AS wins
FROM teams
WHERE wswin = 'N'
 AND yearid >= 1970
 AND yearid <> 1981
 ORDER BY wins DESC
LIMIT 1
---ANSWER: SEA

-------TEAMS WITH LEAST WINS AND WS-----
SELECT teamid, yearid, w AS wins
FROM teams
WHERE wswin = 'Y'
 AND yearid >= 1970
 AND yearid <> 1981
 ORDER BY wins
 LIMIT 1
---Answer: SLN
 
-----Combined Query---
SELECT
no_ws.teamid AS team_no_ws,
no_ws.yearid AS year_no_ws,
no_ws.w AS most_wins_no_ws,
with_ws.teamid AS team_with_ws,
with_ws.yearid AS year_with_ws, 
with_ws.w AS fewest_wins_with_ws
FROM (
SELECT teamid, yearid, w
FROM teams
WHERE wswin = 'N'
	AND yearid >=1970
	AND yearid <> 1981
ORDER BY w DESC
LIMIT 1	) AS no_ws
CROSS JOIN (
SELECT teamid, yearid, w
FROM teams
WHERE wswin = 'Y'
AND yearid >= 1970
AND yearid <> 1981
ORDER BY w DESC
LIMIT 1) AS with_ws

--- ANSWER EXLCUDING 1981 SEA,NYA


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


-- **Open-ended questions**

-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--   *  Does there appear to be any correlation between attendance at home games and number of wins? </li>
--   *  Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.

-- 13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

