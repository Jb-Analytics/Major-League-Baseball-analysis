-- I will start by exploring the players table to understand the structure of the data and the relationships between the columns. Then, I will calculate the age at debut, age at final game, and career length for each player, determine the teams they played for in their starting and ending years, and analyze how many players started and ended on the same team while having a career length of over a decade.

-- 1. View the players table and find the number of players in the table
SELECT
    *
FROM
    players;
SELECT
    COUNT(DISTINCT playerid) AS num_players
FROM
    players;

-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
-- I will use the birthyear, debut, and finalgame columns to calculate the age at debut, age at final game, and career length for each player. I will use the EXTRACT function to get the year from the date columns and perform the necessary calculations.
WITH birthdate AS (
    SELECT
        playerid,
        namegiven,
        CAST(CONCAT(birthyear,'-',birthmonth,'-',birthday) AS DATE) AS birthdate,
        debut,
        finalgame
    FROM
        players
    WHERE birthyear IS NOT NULL
      AND birthmonth IS NOT NULL
      AND birthday IS NOT NULL
      AND debut IS NOT NULL
      AND finalgame IS NOT NULL
)
SELECT
    namegiven,
    EXTRACT(YEAR FROM AGE(debut, birthdate)) AS starting_age,
    EXTRACT(YEAR FROM AGE(finalgame, birthdate)) AS ending_age,
    EXTRACT(YEAR FROM AGE(finalgame, debut)) AS career_length
FROM
    birthdate
ORDER BY
    career_length DESC;

-- 3. What team did each player play on for their starting and ending years?
-- I will join the players table with the schools table to get the schoolid for each player's debut and final game years.

SELECT
    p.namegiven,
    EXTRACT(YEAR FROM p.debut) AS starting_year,
    s.teamid AS starting_team,
    EXTRACT(YEAR FROM p.finalgame) AS ending_year,
    s2.teamid AS ending_team
FROM players p  INNER JOIN salaries s 
                    ON p.playerid = s.playerid AND EXTRACT(YEAR FROM p.debut) = s.yearid
                INNER JOIN salaries s2 
                    ON p.playerid = s2.playerid AND EXTRACT(YEAR FROM p.finalgame) = s2.yearid;

-- 4. How many players started and ended on the same team and also played for over a decade?
-- I will us the two previous queries to create a CTE to calculate the starting and ending teams for each player, and then filter the results to count how many players started and ended on the same team while having a career length of over 10 years.
WITH player_career AS ( SELECT
                            p.namegiven,
                            EXTRACT(YEAR FROM p.debut) AS starting_year,
                            s.teamid AS starting_team,
                            EXTRACT(YEAR FROM p.finalgame) AS ending_year,
                            s2.teamid AS ending_team,
                            (EXTRACT(YEAR FROM AGE(p.finalgame, p.debut))) AS career_length
                        FROM players p  INNER JOIN salaries s 
                                            ON p.playerid = s.playerid AND EXTRACT(YEAR FROM p.debut) = s.yearid
                                        INNER JOIN salaries s2 
                                            ON p.playerid = s2.playerid AND EXTRACT(YEAR FROM p.finalgame) = s2.yearid)
SELECT
    COUNT(*) AS num_players
FROM
    player_career
WHERE starting_team = ending_team
      AND career_length > 10;