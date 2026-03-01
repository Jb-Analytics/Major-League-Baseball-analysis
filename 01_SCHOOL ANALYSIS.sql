-- I will start by exploring the schools and school details tables to understand the structure of the data and the relationships between them. Then, I will analyze the number of schools that produced players in each decade, identify the top 5 schools that produced the most players, and determine the top 3 schools for each decade.

-- 1. View the schools and school details tables
SELECT
    *
FROM
    schools;

SELECT
    *
FROM
    school_details;

-- 2. In each decade, how many schools were there that produced players? 
-- I will use the schools table to count the distinct schoolid for each decade based on the yearid of the players.
SELECT
    (yearid / 10) * 10 AS decade,
    COUNT(DISTINCT schoolid) AS num_schools
FROM
    schools
GROUP BY
    decade
ORDER BY
    decade;

-- 3. What are the names of the top 5 schools that produced the most players?
-- I will join the schools table with the school_details table to get the school names and count the number of players produced by each school. I will then order the results by the number of players and limit it to the top 5.
SELECT
    sd.name_full AS school_name,
    COUNT(DISTINCT s.playerid) AS num_players
FROM
    schools s
    LEFT JOIN school_details sd ON s.schoolid = sd.schoolid
GROUP BY
    s.schoolid,
    sd.name_full
ORDER BY
    num_players DESC
LIMIT
    5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
-- I will use a similar approach as in question 3. My previous request will be turned into a CTE. I will group the results by decade and use a window function to rank the schools within each decade. I will then filter the results to get the top 3 schools for each decade.
WITH
    school_player_counts AS (
        SELECT
            (s.yearid / 10) * 10 AS decade,
            sd.name_full AS school_name,
            COUNT(DISTINCT s.playerid) AS num_players
        FROM
            schools s
            LEFT JOIN school_details sd ON s.schoolid = sd.schoolid
        GROUP BY
            decade,
            school_name
    ),
    ranked_schools AS (
        SELECT
            decade,
            school_name,
            num_players,
            ROW_NUMBER() OVER (
                PARTITION BY
                    decade
                ORDER BY
                    num_players DESC
            ) AS top_school_rank
        FROM
            school_player_counts
    )
SELECT
    decade,
    school_name,
    num_players,
    top_school_rank
FROM
    ranked_schools
WHERE
    top_school_rank <= 3
ORDER BY
    decade,
    num_players DESC;