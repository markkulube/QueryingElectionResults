-- My solution was strongly inspired by that of 
-- Jonny Kong CSC343 FALL 2017

-- winning_partys

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
       countryName VARCHaR(100),
       partyName VARCHaR(100),
       partyFamily VARCHaR(100),
       wonElections INT,
       mostRecentlyWonElectionId INT,
       mostRecentlyWonElectionYear INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS wnVte CASCADE;
DROP VIEW IF EXISTS winning_party CASCADE;
DROP VIEW IF EXISTS num_win CASCADE;
DROP VIEW IF EXISTS avg_win_per_country CASCADE;
DROP VIEW IF EXISTS final_party CASCADE;
DROP VIEW IF EXISTS final_less_five_attributes CASCADE;
DROP VIEW IF EXISTS final_less_four_attributes CASCADE;
DROP VIEW IF EXISTS final_less_three_attributes CASCADE;
DROP VIEW IF EXISTS final_less_two_attributes CASCADE;
DROP VIEW IF EXISTS most_recent_election_won CASCADE;

-- Define views for your intermediate steps here.

-- Find the winning vote count of an election.
CREATE VIEW wnVte AS 
SELECT election_id, max(votes) AS maxVte 
FROM election_result 
GROUP BY election_id ;

 --Find the winning party for each election.
CREATE VIEW winning_party AS
SELECT party.id AS party_id, party.country_id, election_result.election_id
FROM (election_result NATURAL JOIN wnVte )JOIN party ON party.id = election_result.party_id
WHERE wnVte.maxVte = election_result.votes ;

--Find the total number of wins for each party.
CREATE VIEW num_win AS
SELECT num.party_id, party.country_id, num.numPartyWins
FROM(SELECT winning_party.party_id , count(party.country_id) AS numPartyWins 
FROM winning_party  RIGHT JOIN party ON winning_party.party_id = party.id GROUP BY party_id ) num  
      LEFT JOIN party ON party.id= num.party_id;

--Find the average number of elections won per party in each country
CREATE VIEW avg_win_per_country AS
SELECT party.country_id, (sum(num_win.numPartyWins)/count(party.id) )AS average 
FROM num_win RIGHT JOIN party ON num_win.party_id = party.id GROUP BY party.country_id ;

--Find the party that that have won three times the average number of winning elections of parties of the same country
CREATE VIEW final_party AS
SELECT n.party_id ,c.country_id FROM num_win n JOIN avg_win_per_country c ON n.country_id = c.country_id 
WHERE 3*(c.average) < n.numPartyWins ;

--Anwser except mostRecentlyWonElectionId and mostRecentlyWonElectionYear
CREATE VIEW final_less_five_attributes AS
SELECT a.party_id,c.name AS countryName
FROM final_party a JOIN country c ON a.country_id=c.id;

CREATE VIEW final_less_four_attributes AS
SELECT a.party_id, a.countryName, p.name AS partyName
FROM final_less_five_attributes a JOIN party p ON a.party_id=p.id;

CREATE VIEW final_less_three_attributes AS
SELECT a.party_id,a.countryName, a.partyName, pf.family AS partyFamily
FROM final_less_four_attributes a LEFT JOIN party_family pf ON a.party_id=pf.party_id;

CREATE VIEW final_less_two_attributes AS
SELECT a.party_id,a.countryName, a.partyName, a.partyFamily, n.numPartyWins AS wonElections
FROM final_less_three_attributes a JOIN num_win n ON a.party_id = n.party_id;

--Find the most recentwon election for each party.
CREATE VIEW most_recent_election_won AS
SELECT recent.party_id,winning_party.election_id AS mostRecentlyWonElectionId, recent. mostRecentlyWonElectionDate
FROM ((SELECT winning_party.party_id, MAX(election.e_date) AS mostRecentlyWonElectionDate
     FROM winning_party LEFT JOIN election ON winning_party.election_id = election.id 
     GROUP BY winning_party.party_id) recent JOIN winning_party ON recent.party_id = winning_party.party_id) 
     JOIN election ON election.id = winning_party.election_id AND cast(recent.mostRecentlyWonElectionDate AS DATE) = election.e_date;

-- the answer to the query
insert into q1 
SELECT f.countryName,f.partyName,f.partyFamily,f.wonElections, n.mostRecentlyWonElectionId,EXTRACT(year FROM n.mostRecentlyWonElectionDate ) AS mostRecentlyWonElectionYear 
FROM final_less_two_attributes f JOIN most_recent_election_won n ON f.party_id = n.party_id;

