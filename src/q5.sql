-- My solution was strongly inspired by that of 
-- Jonny Kong CSC343 FALL 2017

-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q5 CASCADE;
CREATE TABLE q5(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS alliance_pairs CASCADE;
DROP VIEW IF EXISTS election_count_per_country CASCADE;

-- Define views for your intermediate steps here.

-- Find alliance_pairs of parties that formed an alliance in each country
CREATE VIEW alliance_pairs AS
SELECT e_result1.party_id AS p1, e_result2.party_id AS p2, e_result1.election_id, election.country_id
FROM election_result e_result1, election_result e_result2, election
WHERE e_result1.election_id = e_result2.election_id AND
        (e_result1.alliance_id = e_result2.id OR e_result1.id = e_result2.alliance_id OR e_result1.alliance_id = e_result2.alliance_id) AND
        e_result1.election_id = election.id AND
        e_result1.party_id < e_result2.party_id
GROUP BY(e_result1.election_id, e_result1.party_id, e_result2.party_id, election.country_id);

-- Number of elections per country
CREATE VIEW election_count_per_country AS
SELECT country_id, COUNT(*) AS election_count
FROM election
GROUP BY country_id;

-- Result Set
-- Report the pair of parties that have been allies with each other in at least 
-- 30% of elections that have happened in a country
insert into q5 
SELECT alliance_pairs.country_id AS countryId, 
        alliance_pairs.p1 AS alliedPartyId1, 
        alliance_pairs.p2 AS alliedPartyId2
FROM alliance_pairs, election_count_per_country
WHERE alliance_pairs.country_id = election_count_per_country.country_id
GROUP BY alliance_pairs.p1, alliance_pairs.p2, alliance_pairs.country_id, election_count_per_country.election_count
HAVING COUNT(*) >= (election_count_per_country.election_count::numeric * 0.3);
