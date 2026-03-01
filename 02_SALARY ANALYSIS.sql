-- I will start by exploring the salaries table to understand the structure of the data and the relationships between the columns. Then, I will analyze the top 20% of teams in terms of average annual spending, calculate the cumulative sum of spending for each team over the years, and determine the first year that each team's cumulative spending surpassed 1 billion.

-- 1. View the salaries table
SELECT
    *
FROM
    salaries;

-- 2. Return the top 20% of teams in terms of average annual spending
-- I will calculate the annual spending for each team by grouping the salaries table by teamid and yearid, and then averaging the spending column. I will then use window functions to determine the cutoff for the top 20%.
WITH
    team_spending AS (
        SELECT
            teamid,
            yearid,
            SUM(salary) AS total_spending -- Convert to millions for easier readability
        FROM
            salaries
        GROUP BY
            teamid,
            yearid
    ),
    ranked_teams AS (
        SELECT
            teamid,
            AVG(total_spending) AS avg_spending,
            NTILE (5) OVER (
                ORDER BY
                    AVG(total_spending) DESC
            ) AS spending_rank
        FROM
            team_spending
        GROUP BY
            teamid
    )
SELECT
    teamid,
    ROUND(avg_spending / 1000000, 1) AS avg_spending_millions
FROM
    ranked_teams
WHERE
    spending_rank = 1 -- Top 20% of teams
ORDER BY
    avg_spending DESC;
    
-- 3. For each team, show the cumulative sum of spending over the years
-- I will use a window function to calculate the cumulative sum of spending for each team ordered by yearid. I will first create a CTE to calculate the annual spending for each team and then apply the window function to get the cumulative spending.
WITH
    team_annual_spending AS (
        SELECT
            teamid,
            yearid,
            SUM(salary) AS annual_spending
        FROM
            salaries
        GROUP BY
            teamid,
            yearid
    )
SELECT
    teamid,
    yearid,
    ROUND(
        SUM(annual_spending) OVER (
            PARTITION BY
                teamid
            ORDER BY
                yearid
        ) / 1000000,
        1
    ) AS cumulative_spending_millions
FROM
    team_annual_spending
ORDER BY
    teamid,
    yearid;

-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
-- I will use the cumulative spending calculated in the previous question and filter for the first year where the cumulative spending exceeds 1 billion. I will group the results by teamid and use the MIN function to get the earliest year that meets this condition.
WITH
    team_annual_spending AS (
        SELECT
            teamid,
            yearid,
            SUM(salary) AS annual_spending
        FROM
            salaries
        GROUP BY
            teamid,
            yearid
    ),
    cumulative_spending AS (
        SELECT
            teamid,
            yearid,
            SUM(annual_spending) OVER (
                PARTITION BY
                    teamid
                ORDER BY
                    yearid
            ) AS cumulative_spending
        FROM
            team_annual_spending
    )
SELECT
    teamid,
    MIN(yearid) AS year_surpassed_1billion
FROM
    cumulative_spending
WHERE
    cumulative_spending > 1000000000 -- 1 billion in dollars
GROUP BY
    teamid;