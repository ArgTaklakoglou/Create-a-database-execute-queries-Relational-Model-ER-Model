USE `e-propertiesdb`;

#Task_a
SELECT DISTINCT p.propid AS "Property" , p.address AS "Address"
FROM property AS p, region AS r, evaluation AS e
WHERE p.location = r.regid
	AND r.avg_inc> 40000
    AND p.propid = e.prop_id
    AND e.est_date BETWEEN '2020-12-24' AND '2020-12-31';

#Task_b
CREATE VIEW myV (e, con) AS
SELECT e.evid, count(*)
FROM evaluator AS e, evaluation as ev
WHERE  e.evid = ev.evaluator_id
	AND YEAR(est_date) = 2020
GROUP BY e.evid;

SELECT evid AS "Evaluator", IFNULL(con,0) AS "Total Evaluations for 2020"
FROM evaluator
LEFT JOIN myV ON evid = e
ORDER BY evid;

#Task_c
SELECT propid AS "Property", count(*) AS "Evaluations"
FROM property AS p, evaluation as e
WHERE p.propid = e.prop_id
	AND YEAR(est_date) = 2020
GROUP BY propid
HAVING count(*) > 2;


#Task_d
SELECT evcode AS "Evaluation"
FROM evaluation
WHERE prop_id IN (SELECT propid
			FROM property
			WHERE location IN (SELECT regid
						FROM region
						WHERE avg_inc> 25000));

#Task_e
SELECT  count(*) AS "#of Evaluations"
FROM evaluation AS e, property AS p, region AS r
WHERE e.prop_id = p.propid AND 
	p.location = r.regid AND
	r.population> 50000 AND
	YEAR(e.est_date) = 2020;

#Task_f
SELECT r.regid AS 'Region', (AVG(e.price))/p.size AS 'Price/square meter'
FROM region AS r, evaluation AS e, property AS p
WHERE e.prop_id = p.propid AND p.location = r.regid
GROUP BY r.regid
ORDER BY (AVG(e.price))/p.size ASC;

#Task_g
CREATE VIEW V1(Evaluators, count_Houses) as
SELECT tor.evid AS Evaluators, count(*) AS count_Houses
FROM evaluator AS tor, evaluation AS ion, property AS p, house AS h
WHERE ion.evaluator_id = tor.evid AND ion.prop_id = p.propid AND h.house_propid = p.propid AND YEAR(ion.est_date) = 2020 AND p.houseORoffice = 0
GROUP BY tor.evid;

CREATE VIEW V2(Evaluators, count_Offices) as
SELECT tor.evid AS Evaluators, count(*) AS count_Offices
FROM evaluator AS tor, evaluation AS ion, property AS p, office AS o
WHERE ion.evaluator_id = tor.evid AND ion.prop_id = p.propid AND o.office_propid = p.propid AND YEAR(ion.est_date) = 2020 AND p.houseORoffice = 1
GROUP BY tor.evid;

SELECT evid AS "Evaluator ID",
 IFNULL(count_Houses, 0) AS "Houses Evaluated",
 IFNULL(count_Offices, 0) AS "Offices Evaluated"
FROM evaluator
LEFT JOIN V1 ON evid = V1.Evaluators
LEFT JOIN V2 ON evid = V2.Evaluators;

#Task_h
CREATE VIEW reg2019 (REG,PSM)
AS
SELECT r.regid AS 'REG', (AVG(e.price))/p.size AS 'PSM'
FROM region AS r, evaluation AS e, property AS p
WHERE e.prop_id = p.propid AND p.location = r.regid AND YEAR(e.est_date) = 2019
GROUP BY r.regid
ORDER BY (AVG(e.price))/p.size ASC;

CREATE VIEW reg2020 (REG,PSM)
AS
SELECT r.regid AS 'REG', (AVG(e.price))/p.size AS 'PSM'
FROM region AS r, evaluation AS e, property AS p
WHERE e.prop_id = p.propid AND p.location = r.regid AND YEAR(e.est_date) = 2020
GROUP BY r.regid
ORDER BY (AVG(e.price))/p.size ASC;

SELECT r.regid as "Region",
 IFNULL(reg2020.PSM-reg2019.PSM,0) as "Diff in 2019-2020"
FROM region AS r
LEFT JOIN reg2019 ON r.regid = reg2019.REG
LEFT JOIN reg2020 ON r.regid = reg2020.REG
GROUP BY r.regid;


SELECT e.evid AS 'Evaluator', count(ev.evcode), count(ev.evcode)
FROM evaluator as e, evaluation as ev, house as h, office as o
WHERE e.evid = ev.evaluator_id AND 
	YEAR(ev.est_date) = 2020 AND 
	ev.prop_id = h.house_propid OR
    ev.prop_id = o.office_propid
GROUP BY e.evid;

#task i
CREATE VIEW TEV (REG, Teval) AS
SELECT r.regid AS 'Region', concat(round(( count(*)/
(SELECT count(*) AS 'Total Evaluations'
FROM evaluation as e
WHERE YEAR(e.est_date) = 2020) *100),2),'%') AS "RegEvals"
FROM region as r, evaluation as ev, property as p
WHERE r.regid = p.location AND p.propid = ev.prop_id AND YEAR(ev.est_date) = 2020 
GROUP BY r.regid;

CREATE VIEW TPOP (REG,Tpopul) AS
SELECT r.regid AS 'Region', concat(round((r.population/
(SELECT sum(r.population) AS "Total Population" 
FROM region as r) *100),2),'%') AS "% of Total Population"
FROM region as r
GROUP BY r.regid;

SELECT regid AS 'Region' , IFNULL(TEV.Teval,concat(0.0,'%')) AS "% of Total Evaluations",
 IFNULL(TPOP.Tpopul,concat(0.0,'%')) AS "% of Total Population"
FROM region
LEFT JOIN TEV ON TEV.REG = regid
LEFT JOIN TPOP ON TPOP.REG = regid;