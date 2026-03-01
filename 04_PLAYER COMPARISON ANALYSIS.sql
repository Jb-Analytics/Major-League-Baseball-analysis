-- I will start by exploring the players table to understand the structure of the data and the relationships between the columns. Then, I will analyze which players have the same birthday, create a summary table that shows for each team what percent of players bat right, left, and both, and analyze how average height and weight at debut game have changed over the years along with the decade-over-decade difference.

-- 1. View the players table
SELECT
    *   
FROM    players;

-- 2. Which players have the same birthday?
-- I will use the birthyear, birthmonth, and birthday columns to find players who share the same birthday. I will concatenate these columns to create a full birthdate and then group by this birthdate to find duplicates.
WITH birthdates AS (
    SELECT
        namegiven,
        MAKE_DATE(birthyear,birthmonth,birthday) AS birthdate
    FROM
        players)
SELECT
    birthdate,
    string_agg(namegiven, ', ') AS players
FROM    birthdates
WHERE EXTRACT (YEAR FROM birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
-- I will join the players table with the salaries table to get the teamid for each player. Then, I will use conditional aggregation to calculate the percentage of players that bat right, left, and both for each team.
SELECT
    s.teamid,
    ROUND(100.0 * SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerid), 2) AS bats_right,
    ROUND(100.0 * SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerid), 2) AS bats_left,
    ROUND(100.0 * SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerid), 2) AS bats_both
FROM
    salaries s
    LEFT JOIN players p ON s.playerid = p.playerid
GROUP BY
    s.teamid;

-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
-- I will use the debut column to extract the year of debut for each player and then calculate the average height and weight for each debut year. I will then calculate the decade-over-decade difference by using a window function to compare the averages of each decade with the previous decade.
WITH debut_stats AS (
    SELECT
        (EXTRACT(YEAR FROM debut)::int / 10) * 10 AS decade,
        AVG(height) AS avg_height,
        AVG(weight) AS avg_weight
    FROM
        players
    WHERE debut IS NOT NULL
    GROUP BY
        decade
)   
SELECT
    decade,
    ROUND(avg_height - LAG(avg_height) OVER (ORDER BY decade), 2) AS height_change,
    ROUND(avg_weight - LAG(avg_weight) OVER (ORDER BY decade), 2) AS weight_change
FROM
    debut_stats
ORDER BY
    decade;