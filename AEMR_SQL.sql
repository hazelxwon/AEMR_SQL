--I used this to orient myself to the data table
SELECT*
FROM dbo.AEMR;

--Find the count of valid events in 2016 (i.e. Status = Approved)
SELECT COUNT(*) AS Total_Number_Outage_Events,
  Status,
  Reason 
FROM dbo.AEMR
WHERE Status = 'Approved' AND
    YEAR(Start_Time)=2016
GROUP BY Status, Reason

--What type of outages are most frequent in 2017?
SELECT COUNT(*) AS Total_Number_Outage_Events,
  Status,
  Reason 
FROM dbo.AEMR
WHERE Status = 'Approved' AND
    YEAR(Start_Time)=2017
GROUP BY Status, Reason
ORDER BY Reason;

--What are the average duration of outages (in hours) by reason?
SELECT
  Status,
  Reason, 
  COUNT(*) AS Total_Number_Outage_Events,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)/1440),2) AS Average_Outage_Duration_Time_Days,
  YEAR(Start_Time) AS Year
FROM dbo.AEMR
WHERE Status = 'Approved' AND
    YEAR(Start_Time) IN (2016, 2017)
GROUP BY Status, Reason, YEAR(Start_Time)
ORDER BY Reason, YEAR(Start_Time);



--Monthly Count of outage types in 2016?
SELECT
  Status,
  Reason,
  COUNT(*) AS Total_Number_Outage_Events,
  MONTH(Start_Time) AS Month
FROM dbo.AEMR
WHERE YEAR(Start_Time)=2016 AND Status = 'Approved'
GROUP BY Status, Reason, MONTH(Start_Time)
ORDER BY Reason, MONTH(Start_Time)

--Repeat previous query for 2017
SELECT
  Status,
  Reason,
  COUNT(*) AS Total_Number_Outage_Events,
  MONTH(Start_Time) AS Month
FROM dbo.AEMR
WHERE YEAR(Start_Time)=2017 AND Status = 'Approved'
GROUP BY Status, Reason, MONTH(Start_Time)
ORDER BY Reason, MONTH(Start_Time)

--Monthly outages for all outage types, by month and year?
SELECT
  Status,
  COUNT(*) AS Total_Number_Outage_Events,
  MONTH(Start_Time) AS Month,
  YEAR(Start_Time) AS Year
FROM dbo.AEMR
WHERE Status = 'Approved'
GROUP BY Status, MONTH(Start_Time), YEAR(Start_Time)
ORDER BY Month, Year

--Total Outage Events by Participant Code (Provider)
SELECT
  COUNT(*) AS Total_Number_Outage_Events,
  Participant_Code,
  Status,
  YEAR(Start_Time) AS Year
FROM dbo.AEMR
WHERE Status = 'Approved'
GROUP BY 2, 3, 4
ORDER BY 1 DESC;

--Average duration (days) of all approved outage types for all participants?
SELECT
  Participant_Code,
  Status,
  YEAR(Start_Time) AS Year,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)/1440),2) AS Average_Outage_Duration_Time_Days
FROM dbo.AEMR
WHERE Status = 'Approved'
GROUP BY Participant_Code, Status, YEAR(Start_Time)
ORDER BY Average_Outage_Duration_Time_Days DESC;


--Count of Approved Forced Outage Events? (Where Status=”Forced”)
SELECT
  COUNT(*) AS Total_Number_Outage_Events,
  Reason,
  YEAR(Start_Time) AS Year
FROM dbo.AEMR
WHERE Status = "Approved" AND Reason = "Forced"
GROUP BY Reason, YEAR(Start_Time)
ORDER BY Reason, YEAR(Start_Time);

--Proportion of Forced Outages by Year?
SELECT *,
  100*(Total_Number_Forced_Outage_Events/Total_Number_Outage_Events) AS Forced_Outage_Percentage
FROM(
    SELECT
      SUM(CASE WHEN REASON = "Forced" THEN 1
      ELSE 0 END) AS Total_Number_Forced_Outage_Events,
      COUNT(*) AS Total_Number_Outage_Events,
      YEAR(Start_Time) AS Year
    FROM AEMR
    WHERE Status = "Approved"
    GROUP BY YEAR(Start_Time)
    ORDER BY YEAR(Start_Time)) sub

--Energy volume lost and duration by Participant Code (provider)?
SELECT
  Participant_Code,
  Reason,
  Count(*) AS Outages,
  MONTH(Start_Time) AS Month,
  YEAR(Start_Time) AS Year,
  AVG(Outage_MW) AS Energy_Lost_MW,
  ROUND(
      AVG(
        TIMESTAMPDIFF(MINUTE,Start_Time,End_Time)/1440),2) AS Average_Outage_Duration_Time_Days
FROM dbo.AEMR
WHERE Status = 'Approved'
GROUP BY Participant_Code, Reason, Month, Year;

--Average duration and energy lost by approved forced outages?
SELECT
  Status,
  YEAR(Start_Time) AS Year,
  ROUND(AVG(Outage_MW),2) AS Avg_Outage_MW_Loss,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)),2) AS Average_Outage_Duration_Time_Minutes
FROM dbo.AEMR
WHERE Status = "Approved" AND Reason = "Forced"
GROUP BY Status, YEAR(Start_Time)
ORDER BY YEAR(Start_Time)

--Average duration/energy lost by all types of approved outages?
SELECT
  Status,
  Reason,
  YEAR(Start_Time) AS Year,
  ROUND(AVG(Outage_MW),2) AS Avg_Outage_MW_Loss,
  ROUND(AVG(TIMESTAMPDIFF(MINUTE, Start_Time, End_Time)),2) AS Average_Outage_Duration_Time_Minutes
FROM dbo.AEMR
WHERE Status = "Approved"
GROUP BY Status, Reason, YEAR(Start_Time)
ORDER BY YEAR(Start_Time)

--Which providers (participant_code) have highest energy losses?
SELECT
  Participant_Code,
  Facility_Code, 
  Status,
  YEAR(Start_Time) AS Year,
  ROUND(AVG(Outage_MW),2) AS Avg_Outage_MW_Loss,
  ROUND(SUM(Outage_MW),2) AS Summed_Energy_Lost
FROM dbo.AEMR
WHERE Status = "Approved" AND Reason= "Forced" 
GROUP BY Participant_Code, Facility_Code, Status, YEAR(Start_Time)
ORDER BY Summed_Energy_Lost DESC, YEAR(Start_Time)
