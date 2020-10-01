-- My solution was strongly inspired by that of 
-- Jonny Kong CSC343 FALL 2017

-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

CREATE TABLE q3(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinet_count_per_country CASCADE;
DROP VIEW IF EXISTS cabinet_count_per_party CASCADE;
DROP VIEW IF EXISTS party_valid CASCADE;

-- Define views for your intermediate steps here.

-- Find the number of cabinets of each country between 1996-2016
CREATE VIEW cabinet_count_per_country AS
SELECT country_id, COUNT(DISTINCT id) AS cabinet_count
FROM cabinet
WHERE start_date >= '1996-01-01' AND 
        start_date < '2017-01-01'
GROUP BY country_id;

-- Find the number of times each party each party has been in cabinet
CREATE VIEW cabinet_count_per_party AS
SELECT cabinet_party.party_id, 
        COUNT(cabinet.id) AS party_count,  
        cabinet.country_id
FROM cabinet_party, cabinet
WHERE cabinet_party.cabinet_id = cabinet.id AND
        cabinet.start_date >= '1996-01-01' AND
        cabinet.start_date < '2017-01-01'
GROUP BY cabinet_party.party_id, cabinet.country_id;

-- Select party id that in all cabinets
CREATE VIEW party_valid AS
SELECT cabinet_count_per_party.party_id,
        cabinet_count_per_party.country_id
FROM cabinet_count_per_country, 
        cabinet_count_per_party
WHERE cabinet_count_per_country.country_id = cabinet_count_per_party.country_id AND
        party_count = cabinet_count;

-- Result Set
insert into q3 
SELECT country.name AS countryName,
        party.name AS partyName,
        party_family.family AS partyFamily,
        party_position.state_market AS stateMarket
FROM party_valid, country, party, party_family, party_position
WHERE party_valid.country_id = country.id AND
        party_valid.party_id = party.id AND
        party_valid.party_id = party_family.party_id AND
        party_valid.party_id = party_position.party_id;
