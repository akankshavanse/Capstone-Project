use football;

-- ******************************************SPRINT 3****************************************** --
-- Performance analysis
-- Descriptive questions
-- 1.Question: Which players have the highest goals-per-game ratio, and how does it relate to their market value?
SELECT p.name as player_name, 
       AVG(a.goals) AS avg_goals_per_game, 
       p.market_value_in_eur
FROM players_cleaned p
JOIN appearances_cleaned a ON p.player_id = a.player_id
GROUP BY p.name, p.market_value_in_eur
ORDER BY avg_goals_per_game DESC;

/*  
Interpretation: 
1. Aron Johannsson leads with an average of 0.4318 goals per game but has a relatively low market value of 400,000 EUR.
2. Players like Jozy Altidore (0.3765) and Andrija Novakovich (0.3333) also show solid performance with modest market values of 500,000 EUR and 900,000 EUR, respectively.
3. Folarin balogun has the highest market value of 30M  EUR

*/


-- 2.Question: How has the performance (win/loss ratio) of each team evolved over the seasons?
SELECT season, home_club_name AS club, 
       SUM(CASE WHEN home_club_goals > away_club_goals THEN 1 ELSE 0 END) AS wins,
       SUM(CASE WHEN home_club_goals < away_club_goals THEN 1 ELSE 0 END) AS losses
FROM games_cleaned
GROUP BY season, home_club_name
ORDER BY season, club;



-- 3. Question: Does higher stadium attendance correlate with better performance for home teams?
SELECT stadium, 
       AVG(attendance) AS avg_attendance, 
       SUM(CASE WHEN home_club_goals > away_club_goals THEN 1 ELSE 0 END) AS home_wins
FROM games_cleaned
GROUP BY stadium
ORDER BY avg_attendance DESC;

/*
Interpretation: 
*/

-- 4. Question: Which players and teams have the highest discipline issues (yellow and red cards)?
SELECT p.name, COUNT(a.yellow_cards) AS yellow_cards, 
       COUNT(a.red_cards) AS red_cards, g.home_club_name
FROM appearances_cleaned a
JOIN players_cleaned p ON a.player_id = p.player_id
JOIN games_cleaned g ON a.game_id = g.game_id
GROUP BY p.name, g.home_club_name
ORDER BY yellow_cards DESC, red_cards DESC;

/*
Interpretations: Top Offenders: Players like Geoff Cameron and Fabian Johnson lead with the highest yellow and red card counts, indicating a tendency for aggressive play.

Team Trends: Stoke City and Borussia Verein für Leibesübung 1900 e.V. show significant disciplinary issues, suggesting a possible connection between their playing style and higher card counts.
*/



-- ******************************************SPRINT 6****************************************** --
-- Team Comparison
-- 1. Which team has the highest average attendance per match?
SELECT home_club_name AS team, AVG(attendance) AS average_attendance
FROM games_cleaned
GROUP BY home_club_name
ORDER BY average_attendance DESC
LIMIT 1;


-- 2. What is the total number of goals scored by each team in the current season?
SELECT home_club_name AS team, SUM(home_club_goals) AS total_goals
FROM games_cleaned
WHERE season = '2020'
GROUP BY home_club_name
UNION
SELECT away_club_name AS team, SUM(away_club_goals) AS total_goals
FROM games_cleaned
WHERE season = '2020'
GROUP BY away_club_name
order by total_goals desc ;

-- 3.How do player appearances and goals correlate across teams?
SELECT g.home_club_name AS team,
       COUNT(a.appearance_id) AS total_appearances,
       SUM(a.goals) AS total_goals
FROM appearances_cleaned a
JOIN games_cleaned g ON a.game_id = g.game_id
GROUP BY g.home_club_name;



-- 4. What is the average market value of players per team?
SELECT p.current_club_id AS team, AVG(p.market_value_in_eur) AS average_market_value
FROM players_cleaned p
JOIN game_lineups_cleaned gl ON p.player_id = gl.player_id
GROUP BY p.current_club_id;


SELECT 
    g.referee,
    SUM(a.yellow_cards) AS total_yellow_cards,
    SUM(a.red_cards) AS total_red_cards,
    COUNT(DISTINCT g.game_id) AS total_games,
    AVG(a.yellow_cards) AS avg_yellow_cards,
    AVG(a.red_cards) AS avg_red_cards
FROM 
	appearances_cleaned a
    
JOIN 
    games_cleaned g ON g.game_id = a.game_id
GROUP BY 
    g.referee;
    

-- ******************************************Sprint 10****************************************** --
-- Player Attributes and Demographics
-- 1. What is the age distribution of players across different positions?
select position, floor(datediff(curdate(), date_of_birth) / 365) as age,
count(*) as player_count
from players_cleaned
group by position, age
order by position, age desc;

-- 2. How does player market value differ based on position and nationality?
select position, country_of_birth, avg(market_value_in_eur) as avg_market_value
from players_cleaned
group by position, country_of_birth
order by avg_market_value DESC;

-- 3. What is the distribution of players' height across different leagues?
SELECT 
    g.competition_type, 
    p.position, 
    AVG(p.height_in_cm) AS avg_height, 
    COUNT(p.player_id) AS player_count
FROM players_cleaned p
JOIN appearances_cleaned a ON p.player_id = a.player_id  -- Match player appearance data
JOIN games_cleaned g ON a.game_id = g.game_id            -- Link appearances with competitions
GROUP BY g.competition_type, p.position
ORDER BY g.competition_type, avg_height DESC;

-- 4. How do players' contract expiration dates vary across clubs and competitions?
SELECT 
    p.current_club_id ,
    g.competition_type,
    COUNT(p.player_id) AS number_of_players,
    MIN(p.contract_expiration_date) AS earliest_expiration,
    MAX(p.contract_expiration_date) AS latest_expiration,
    AVG(DATEDIFF(p.contract_expiration_date, CURDATE())) AS avg_days_until_expiration
FROM players_cleaned p
JOIN appearances_cleaned a 
    ON p.player_id = a.player_id
JOIN games_cleaned g 
    ON a.game_id = g.game_id
WHERE p.contract_expiration_date IS NOT NULL
GROUP BY p.current_club_id, g.competition_type
ORDER BY current_club_id, competition_type;