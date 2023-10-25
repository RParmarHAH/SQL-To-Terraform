-- DW_DEV.REPORT.VW_CLIENT_CAREGIVER_RELATIONSHIP source

create materialized view DW_DEV.REPORT.VW_CLIENT_CAREGIVER_RELATIONSHIP(
	CLIENT_KEY,
	CLIENT_NUMBER,
	EMPLOYEE_KEY,
	EMPLOYEE_NUMBER,
	RELATIONSHIP_FIRST_SERVICE_DATE,
	RELATIONSHIP_LATEST_SERVICE_DATE,
	BRANCH_KEY,
	RELATIONSHIP_TENURE,
	CLIENT_FIRST_SERVICE_DATE,
	CLIENT_LATEST_SERVICE_DATE,
	CLIENT_TENURE,
	EMPLOYEE_FIRST_SERVICE_DATE,
	EMPLOYEE_LATEST_SERVICE_DATE,
	CLIENT_DOB,
	EMPLOYEE_DOB,
	DERIVED_EMPLOYEE_CATEGORY,
	CLIENT_ZIP,
	CLIENT_LAT_LONG,
	EMPLOYEE_ZIP,
	EMPLOYEE_LAT_LONG,
	EMPLOYEE_CLIENT_DISTANCE,
	AVG_EMPLOYEE_CLIENT_DISTANCE,
	TOTAL_HOURS_SERVED,
	TOTAL_NUMBER_OF_VISITS,
	AVG_HOURS_PER_VISIT,
	HH_RELATIONSHIP_FIRST_SERVICE_DATE,
	HH_RELATIONSHIP_LATEST_SERVICE_DATE,
	HH_RELATIONSHIP_TENURE,
	CLIENT_HH_FIRST_SERVICE_DATE,
	CLIENT_HH_LATEST_SERVICE_DATE,
	EMPLOYEE_HH_FIRST_SERVICE_DATE,
	EMPLOYEE_HH_LATEST_SERVICE_DATE,
	TOTAL_HH_HOURS_SERVED,
	TOTAL_NUMBER_HH_OF_VISITS,
	HH_AVG_HOURS_PER_VISIT,
	HC_RELATIONSHIP_LATEST_SERVICE_DATE,
	HC_RELATIONSHIP_TENURE,
	CLIENT_HC_FIRST_SERVICE_DATE,
	CLIENT_HC_LATEST_SERVICE_DATE,
	EMPLOYEE_HC_FIRST_SERVICE_DATE,
	EMPLOYEE_HC_LATEST_SERVICE_DATE,
	TOTAL_HC_HOURS_SERVED,
	TOTAL_NUMBER_HC_OF_VISITS,
	HC_AVG_HOURS_PER_VISIT,
	HOURS_IN_REVIEW,
	FUTURE_HOURS,
	FUTURE_CANCELLED_HOURS,
	FUTURE_HOLD_HOURS,
	HOURS_MISSED,
	HOURS_CANCELLED,
	HOURS_RESCHEDULED,
	HOURS_SCHEDULED,
	VISITS_IN_REVIEW,
	FUTURE_VISITS,
	FUTURE_CANCELLED_VISITS,
	FUTURE_HOLD_VISITS,
	VISITS_MISSED,
	VISITS_COMPLETED,
	VISITS_CANCELLED,
	VISITS_RESCHEDULED,
	VISITS_SCHEDULED,
	CLIENT_SERVED_FLAG
) as 
WITH GEN_REL AS (
SELECT DISTINCT V.CLIENT_KEY, CL.CLIENT_NUMBER ,V.EMPLOYEE_KEY, E.EMPLOYEE_NUMBER,
MIN(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) RELATIONSHIP_FIRST_SERVICE_DATE, 
MAX(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) RELATIONSHIP_LATEST_SERVICE_DATE,
V.BRANCH_KEY,
(MAX(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) - MIN(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY)) RELATIONSHIP_TENURE, 
MIN(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_FIRST_SERVICE_DATE,
MAX(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_LATEST_SERVICE_DATE,
(MAX(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.CLIENT_KEY) - MIN(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.CLIENT_KEY)) CLIENT_TENURE, 
MIN(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_FIRST_SERVICE_DATE,
MAX(iff(MAX(CONFIRMED_FLAG) = 'YES',SERVICE_DATE,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_LATEST_SERVICE_DATE,
CL.CLIENT_DOB,
E.EMPLOYEE_DOB,
CASE WHEN E.CASE_MANAGER_FLAG = TRUE THEN 'Admin' ELSE E.EMPLOYEE_CATEGORY END AS DERIVED_EMPLOYEE_CATEGORY,
CL.CLIENT_ZIP, 
CONCAT(CG.LATITUDE,',',CG.LONGITUDE) CLIENT_LAT_LONG,
E.EMPLOYEE_ZIP,
CONCAT(EG.LATITUDE,',',EG.LONGITUDE) EMPLOYEE_LAT_LONG,
HAVERSINE(CG.LATITUDE,CG.LONGITUDE,EG.LATITUDE,EG.LONGITUDE) EMPLOYEE_CLIENT_DISTANCE,
SUM(HAVERSINE(CG.LATITUDE,CG.LONGITUDE,EG.LATITUDE,EG.LONGITUDE))/COUNT(HAVERSINE(CG.LATITUDE,CG.LONGITUDE,EG.LATITUDE,EG.LONGITUDE)) AVG_EMPLOYEE_CLIENT_DISTANCE,
SUM(iff(MAX(CONFIRMED_FLAG) = 'YES',V.HOURS_SERVED,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_HOURS_SERVED,
COUNT(iff(MAX(CONFIRMED_FLAG) = 'YES',V.VISIT_KEY,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_NUMBER_OF_VISITS,
(SUM(iff(MAX(CONFIRMED_FLAG) = 'YES',V.HOURS_SERVED,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)/COUNT(iff(MAX(CONFIRMED_FLAG) = 'YES',V.VISIT_KEY,NULL)) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)) AVG_HOURS_PER_VISIT
FROM INTEGRATION.FACT_VISIT_MERGED V 
LEFT JOIN HAH.DIM_CONTRACT C ON C. CONTRACT_KEY = V.CONTRACT_KEY
LEFT JOIN INTEGRATION.DIM_EMPLOYEE_MERGED E ON E.EMPLOYEE_KEY = V.ORIGINAL_EMPLOYEE_KEY 
LEFT JOIN INTEGRATION.DIM_CLIENT_MERGED CL ON CL.CLIENT_KEY = V.ORIGINAL_CLIENT_KEY  
LEFT JOIN HAH.DIM_GEOGRAPHY CG ON CG.ZIP_CODE = CL.CLIENT_ZIP
LEFT JOIN HAH.DIM_GEOGRAPHY EG ON EG.ZIP_CODE = E.EMPLOYEE_ZIP 
JOIN REPORT.VW_DASHBOARD_CONTRACTS DC ON V.CONTRACT_KEY = DC.CONTRACT_KEY 
--WHERE V.CONFIRMED_FLAG = 'YES' --AND NVL(V.BILL_UNIT_TYPE,'Hourly')='Hourly' --V.STATUS_CODE IN ('02','03','04','05') 
WHERE (DC.INCLUDE_FOR_EXEC_OPS_HOURS = TRUE OR DC.INCLUDE_FOR_EXEC_OPS_CLIENTS = TRUE)
GROUP BY V.VISIT_KEY, V.SERVICE_DATE, V.HOURS_SERVED, V.CLIENT_KEY, CL.CLIENT_NUMBER, V.EMPLOYEE_KEY, E.EMPLOYEE_NUMBER, V.BRANCH_KEY, CL.CLIENT_DOB, E.EMPLOYEE_DOB, CL.CLIENT_ZIP, E.EMPLOYEE_ZIP, E.CASE_MANAGER_FLAG, E.EMPLOYEE_CATEGORY, 
CG.LATITUDE, CG.LONGITUDE, EG.LATITUDE, EG.LONGITUDE 
),
HH_REL AS (
SELECT DISTINCT V.CLIENT_KEY,V.EMPLOYEE_KEY,
MIN(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) HH_RELATIONSHIP_FIRST_SERVICE_DATE, 
MAX(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) HH_RELATIONSHIP_LATEST_SERVICE_DATE,
(MAX(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) - MIN(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY)) HH_RELATIONSHIP_TENURE, 
MIN(V.SERVICE_DATE) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_HH_FIRST_SERVICE_DATE,
MAX(V.SERVICE_DATE) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_HH_LATEST_SERVICE_DATE,
MIN(V.SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_HH_FIRST_SERVICE_DATE,
MAX(V.SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_HH_LATEST_SERVICE_DATE,
SUM(V.HOURS_SERVED) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_HH_HOURS_SERVED,
COUNT(V.VISIT_KEY) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_NUMBER_HH_OF_VISITS,
(SUM(V.HOURS_SERVED) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)/COUNT(V.VISIT_KEY) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)) HH_AVG_HOURS_PER_VISIT
FROM INTEGRATION.FACT_VISIT_MERGED V 
JOIN HAH.DIM_CONTRACT C ON C.CONTRACT_KEY = V.CONTRACT_KEY AND C.REVENUE_CATEGORY = 'HH' 
LEFT JOIN INTEGRATION.DIM_EMPLOYEE_MERGED E ON E.EMPLOYEE_KEY = V.ORIGINAL_EMPLOYEE_KEY 
LEFT JOIN INTEGRATION.DIM_CLIENT_MERGED CL ON CL.CLIENT_KEY = V.ORIGINAL_CLIENT_KEY  
LEFT JOIN HAH.DIM_GEOGRAPHY CG ON CG.ZIP_CODE = CL.CLIENT_ZIP
LEFT JOIN HAH.DIM_GEOGRAPHY EG ON EG.ZIP_CODE = E.EMPLOYEE_ZIP 
WHERE V.CONFIRMED_FLAG = 'YES' --V.STATUS_CODE IN ('02','03','04','05')
GROUP BY V.VISIT_KEY, V.SERVICE_DATE, V.HOURS_SERVED, V.CLIENT_KEY, CL.CLIENT_NUMBER, V.EMPLOYEE_KEY, E.EMPLOYEE_NUMBER, V.BRANCH_KEY, CL.CLIENT_DOB, E.EMPLOYEE_DOB, CL.CLIENT_ZIP, E.EMPLOYEE_ZIP, E.CASE_MANAGER_FLAG, E.EMPLOYEE_CATEGORY, 
CG.LATITUDE, CG.LONGITUDE, EG.LATITUDE, EG.LONGITUDE
),
HC_REL AS (
SELECT DISTINCT V.CLIENT_KEY,V.EMPLOYEE_KEY, 
MIN(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) HC_RELATIONSHIP_FIRST_SERVICE_DATE, 
MAX(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) HC_RELATIONSHIP_LATEST_SERVICE_DATE,
(MAX(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY) - MIN(SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY, V.CLIENT_KEY)) HC_RELATIONSHIP_TENURE, 
MIN(V.SERVICE_DATE) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_HC_FIRST_SERVICE_DATE,
MAX(V.SERVICE_DATE) OVER (PARTITION BY V.CLIENT_KEY) CLIENT_HC_LATEST_SERVICE_DATE,
MIN(V.SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_HC_FIRST_SERVICE_DATE,
MAX(V.SERVICE_DATE) OVER (PARTITION BY V.EMPLOYEE_KEY) EMPLOYEE_HC_LATEST_SERVICE_DATE,
SUM(V.HOURS_SERVED) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_HC_HOURS_SERVED,
COUNT(V.VISIT_KEY) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY) TOTAL_NUMBER_HC_OF_VISITS,
(SUM(V.HOURS_SERVED) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)/COUNT(V.VISIT_KEY) OVER (PARTITION BY V.EMPLOYEE_KEY,V.CLIENT_KEY)) HC_AVG_HOURS_PER_VISIT
FROM INTEGRATION.FACT_VISIT_MERGED V 
JOIN HAH.DIM_CONTRACT C ON C.CONTRACT_KEY = V.CONTRACT_KEY AND C.REVENUE_CATEGORY = 'HC' 
LEFT JOIN INTEGRATION.DIM_EMPLOYEE_MERGED E ON E.EMPLOYEE_KEY = V.ORIGINAL_EMPLOYEE_KEY 
LEFT JOIN INTEGRATION.DIM_CLIENT_MERGED CL ON CL.CLIENT_KEY = V.ORIGINAL_CLIENT_KEY  
LEFT JOIN HAH.DIM_GEOGRAPHY CG ON CG.ZIP_CODE = CL.CLIENT_ZIP
LEFT JOIN HAH.DIM_GEOGRAPHY EG ON EG.ZIP_CODE = E.EMPLOYEE_ZIP 
WHERE V.CONFIRMED_FLAG = 'YES' --V.STATUS_CODE IN ('02','03','04','05')
GROUP BY V.VISIT_KEY, V.SERVICE_DATE, V.HOURS_SERVED, V.CLIENT_KEY, CL.CLIENT_NUMBER, V.EMPLOYEE_KEY, E.EMPLOYEE_NUMBER, V.BRANCH_KEY, CL.CLIENT_DOB, E.EMPLOYEE_DOB, CL.CLIENT_ZIP, E.EMPLOYEE_ZIP, E.CASE_MANAGER_FLAG, E.EMPLOYEE_CATEGORY, 
CG.LATITUDE, CG.LONGITUDE, EG.LATITUDE, EG.LONGITUDE
),
NEW_METRICS AS
	(	
		SELECT 
			CLIENT_KEY,
			BRANCH_KEY,
			EMPLOYEE_KEY,
			sum(HOURS_IN_REVIEW) AS HOURS_IN_REVIEW,
			sum(FUTURE_HOURS) AS FUTURE_HOURS,
			sum(FUTURE_CANCELLED_HOURS) AS FUTURE_CANCELLED_HOURS,
			sum(FUTURE_HOLD_HOURS) AS FUTURE_HOLD_HOURS,
			sum(HOURS_MISSED) AS HOURS_MISSED,
			sum(HOURS_CANCELLED) AS HOURS_CANCELLED,
			sum(HOURS_RESCHEDULED) AS HOURS_RESCHEDULED,
			sum(HOURS_SCHEDULED) AS HOURS_SCHEDULED,
			sum(VISITS_IN_REVIEW) AS VISITS_IN_REVIEW,
			sum(FUTURE_VISITS) AS FUTURE_VISITS,
			sum(FUTURE_CANCELLED_VISITS) AS FUTURE_CANCELLED_VISITS,
			sum(FUTURE_HOLD_VISITS) AS FUTURE_HOLD_VISITS,
			sum(VISITS_MISSED) AS VISITS_MISSED,
			sum(VISITS_COMPLETED) AS VISITS_COMPLETED,
			sum(VISITS_CANCELLED) AS VISITS_CANCELLED,
			sum(VISITS_RESCHEDULED) AS VISITS_RESCHEDULED,
			sum(VISITS_SCHEDULED) AS VISITS_SCHEDULED
		FROM REPORT.SCHEDULE_METRICS_WEEKLY V
		JOIN REPORT.VW_DASHBOARD_CONTRACTS DC ON V.CONTRACT_KEY = DC.CONTRACT_KEY
		WHERE DC.INCLUDE_FOR_EXEC_OPS_HOURS = TRUE OR DC.INCLUDE_FOR_EXEC_OPS_CLIENTS = TRUE
		GROUP BY 
			CLIENT_KEY,
			BRANCH_KEY,
			EMPLOYEE_KEY
	)	
SELECT G.*, HH_RELATIONSHIP_FIRST_SERVICE_DATE, HH_RELATIONSHIP_LATEST_SERVICE_DATE, HH_RELATIONSHIP_TENURE, CLIENT_HH_FIRST_SERVICE_DATE, CLIENT_HH_LATEST_SERVICE_DATE,
EMPLOYEE_HH_FIRST_SERVICE_DATE, EMPLOYEE_HH_LATEST_SERVICE_DATE, TOTAL_HH_HOURS_SERVED, TOTAL_NUMBER_HH_OF_VISITS, HH_AVG_HOURS_PER_VISIT,
HC_RELATIONSHIP_LATEST_SERVICE_DATE, HC_RELATIONSHIP_TENURE, CLIENT_HC_FIRST_SERVICE_DATE, CLIENT_HC_LATEST_SERVICE_DATE,
EMPLOYEE_HC_FIRST_SERVICE_DATE, EMPLOYEE_HC_LATEST_SERVICE_DATE, TOTAL_HC_HOURS_SERVED, TOTAL_NUMBER_HC_OF_VISITS, HC_AVG_HOURS_PER_VISIT,
HOURS_IN_REVIEW,
	FUTURE_HOURS,
	FUTURE_CANCELLED_HOURS,
	FUTURE_HOLD_HOURS,
	HOURS_MISSED,
	HOURS_CANCELLED,
	HOURS_RESCHEDULED,
	HOURS_SCHEDULED,
	VISITS_IN_REVIEW,
	FUTURE_VISITS,
	FUTURE_CANCELLED_VISITS,
	FUTURE_HOLD_VISITS,
	VISITS_MISSED,
	VISITS_COMPLETED,
	VISITS_CANCELLED,
	VISITS_RESCHEDULED,
	VISITS_SCHEDULED,
	IFF(VISITS_COMPLETED = 0, FALSE, TRUE) AS CLIENT_SERVED_FLAG
FROM GEN_REL G
LEFT JOIN HC_REL HC ON HC.CLIENT_KEY=G.CLIENT_KEY AND HC.EMPLOYEE_KEY=G.EMPLOYEE_KEY
LEFT JOIN HH_REL HH ON HH.CLIENT_KEY=G.CLIENT_KEY AND HH.EMPLOYEE_KEY=G.EMPLOYEE_KEY
LEFT JOIN NEW_METRICS NM ON G.CLIENT_KEY = NM.CLIENT_KEY AND G.BRANCH_KEY = NM.BRANCH_KEY AND G.EMPLOYEE_KEY=NM.EMPLOYEE_KEY;
