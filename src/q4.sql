-- My solution was strongly inspired by that of 
-- Jonny Kong CSC343 FALL 2017

-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.

CREATE TABLE q4(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinet_start_end CASCADE;
DROP VIEW IF EXISTS cabinet_start_end_with_pm_pid CASCADE;
DROP VIEW IF EXISTS cabinet_start_end_with_pName CASCADE;
DROP VIEW IF EXISTS cabinet_start_end_with_party_pm CASCADE;

-- Define views for your intermediate steps here.

-- Find start and end dates of each cabinet. Set endDate to NULL for the most recent cabinet.
CREATE VIEW cabinet_start_end AS
SELECT cab1.id AS cabinet_id, cab1.country_id AS country_id, cab1.start_date AS start_date, cab2.start_date AS endDate 
FROM cabinet cab1 LEFT JOIN cabinet cab2 ON cab1.id = cab2.previous_cabinet_id;

-- Find start and end dates of each cabinet and the party id of the prime minister's party of each cabinet.
-- Exclude those without prime minister
CREATE VIEW cabinet_start_end_with_pm_pid AS
SELECT w.country_id, w.cabinet_id, w.start_date, w.endDate, c.party_id
FROM cabinet_start_end w LEFT JOIN cabinet_party c ON w.cabinet_id = c.cabinet_id WHERE c.pm ;

-- Find start and end dates of each cabinet and the party name of the prime minister's party of each cabinet.
-- Exclude those without prime minister
CREATE VIEW cabinet_start_end_with_pName AS
SELECT w.country_id, w.cabinet_id, w.start_date, w.endDate, p.name
FROM cabinet_start_end_with_pm_pid w LEFT JOIN party p ON w.party_id = p.id ;

-- Create a table as cabinet_start_end with the party name of the primary minister party of each cabinet.
-- For those without prime minister, set NULL.
CREATE VIEW cabinet_start_end_with_party_pm AS
SELECT w1.country_id, w1.cabinet_id, w1.start_date, w1.endDate, w2.name
FROM cabinet_start_end w1 LEFT JOIN cabinet_start_end_with_pName w2 ON w1.cabinet_id = w2.cabinet_id ;

-- Result Set 
-- Create a table as cabinet_start_end_with_party_pm but with countryName instead of country_id
insert into q4 

SELECT c.name AS countryName, w.cabinet_id AS cabinetId, w.start_date AS startDate, w.endDate, w.name AS pmParty
FROM cabinet_start_end_with_party_pm w JOIN country c ON w.country_id = c.id ;
