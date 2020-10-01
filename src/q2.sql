-- My solution was strongly inspired by that of 
-- Jonny Kong CSC343 FALL 2017

-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS speculate_votes CASCADE;
DROP VIEW IF EXISTS part_ratio CASCADE;
DROP VIEW IF EXISTS cid_Invalid CASCADE;
DROP VIEW IF EXISTS cid_valid CASCADE;

-- Define views for your intermediate steps here.

-- When votes_cast empty, speculate vote cases from sum of election results
CREATE VIEW speculate_votes AS 
SELECT election.id, election.country_id, election.e_date, electorate,
        (CASE WHEN votes_cast IS NOT NULL THEN votes_cast
        ELSE (
                SELECT SUM(votes) 
                FROM election_result
                WHERE election_result.election_id = election.id)
                END) AS votes_cast
FROM election;


-- Group by country and year
CREATE VIEW part_ratio AS 
SELECT EXTRACT(year FROM e_date) AS year, country_id, AVG(votes_cast::numeric / electorate::numeric) AS ratio
FROM speculate_votes
WHERE e_date > '2001-01-01' AND e_date < '2016-12-31'
GROUP BY year, country_id;

-- SELECT country_id of invalid countries (don't meet criteria)
CREATE VIEW cid_Invalid AS
SELECT DISTINCT country_id
FROM part_ratio
WHERE EXISTS (
        SELECT * 
        FROM part_ratio p
        WHERE 
                part_ratio.year > p.year AND
                part_ratio.ratio < p.ratio);

-- SELECT country_id of countries that are valid (meet critea)
CREATE VIEW cid_valid AS
SELECT id
FROM country
WHERE NOT EXISTS (
        SELECT * 
        FROM cid_Invalid
        WHERE country.id = cid_Invalid.country_id
);


-- result set 
insert into q2 
SELECT country.name AS countryName, 
        part_ratio.year AS year, 
        part_ratio.ratio AS participationRatio
FROM part_ratio, country, cid_valid
WHERE part_ratio.country_id = country.id AND 
        part_ratio.country_id = cid_valid.id; 
