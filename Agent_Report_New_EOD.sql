-- Databricks notebook source

--Agent_report
-- Login1

-- COMMAND ----------

select * from id_temp.agent_summary

-- COMMAND ----------

CREATE OR REPLACE TABLE id_temp.Agent_summary1 AS (
    SELECT 
        `Date` AS Date,
        `Name` AS Name,
        `Username` AS Username,
        `Ready` AS Ready,
        `Manual` AS Manual,
        `Preview` AS Preview,
        `Callback` AS Callback,
        `Stop` AS Stop,
        `CallSetup/Offer` AS CallSetup_Offer,
        `Pause` AS Pause,
        `Headset Test` AS Headset_Test,
        `Ringing` AS Ringing,
        `Talktime` AS Talktime,
        `Mute` AS Mute,
        `Hold` AS Hold,
        `Transfer` AS Transfer,
        `Conference` AS Conference,
        `Dispose` AS Dispose,
        `Call Time` AS Call_Time,
        `Handling Time` AS Handling_Time,
        `Login Time` AS Login_Time,
        `Total Login Hours` AS Total_Login_Hours,
        `Total Calls` AS Total_Calls,
        `Outbound Calls` AS Outbound_Calls,
        `Inbound Calls` AS Inbound_Calls,
        `Answered Calls` AS Answered_Calls,
        `Outbound Answered Calls` AS Outbound_Answered_Calls,
        `Inbound Answered Calls` AS Inbound_Answered_Calls,
        `Not Answered Calls` AS Not_Answered_Calls,
        `Total TalkTime` AS Total_TalkTime,
        `Outbound TalkTime` AS Outbound_TalkTime,
        `Inbound TalkTime` AS Inbound_TalkTime,
        `Average TalkTime` AS Average_TalkTime,
        `Average TalkTime Outbound` AS Average_TalkTime_Outbound,
        `Average TalkTime Inbound` AS Average_TalkTime_Inbound,
        `Average HandlingTime` AS Average_HandlingTime,
        `Average Handling Outbound` AS Average_Handling_Outbound,
        `Average Handling Inbound` AS Average_Handling_Inbound,
        `SAP ID` AS SAP_ID,
        `Email ` AS Email,
        `Briefing pause` AS Briefing_pause,
        `tea break pause` AS tea_break_pause,
        `lunch pause` AS lunch_pause,
        `other pause` AS other_pause,
        `verification pause` AS verification_pause,
        `Training pause` AS Training_pause,
        `Meeting pause` AS Meeting_pause,
        `Utility pause` AS Utility_pause
    FROM id_temp.agent_summary
)

-- COMMAND ----------

CREATE or replace table id_temp.login2 AS
(
  SELECT 
    Date AS Date,
    `Login Time` AS Login_Time,
    `logout Time` AS logout_Time,
    `User Name` AS User_Name
FROM 
     id_temp.login 
)

-- COMMAND ----------


CREATE or replace table id_temp.Agent_Report_Summary as(
   SELECT 
    *,
    last_day(current_date()) AS Business_Date,
    CASE 
        WHEN hour(from_utc_timestamp(current_timestamp(), 'Asia/Kolkata')) > 9 
             AND hour(from_utc_timestamp(current_timestamp(), 'Asia/Kolkata')) < 20 
        THEN 'E.ALL_EOD'
        ELSE NULL 
    END AS TIME_SLOT,
    
    CASE WHEN Username IS NOT NULL THEN 'LOGIN' ELSE '' END AS LOGIN_STATUS,
    
    CASE 
        WHEN left(UserName, 1) IN ('0', '2', '3', '4', '5', '6', '7', '8', '9') 
        THEN 
            -- Employee ID Extract
            regexp_extract(UserName, '([0-9]+)', 0)
        ELSE 
            regexp_extract(UserName, '([0-9]+)', 0)
    END AS Employe_Id


    ,hour(TALKTIME) * 3600 + minute(TALKTIME) * 60 + second(TALKTIME) as TALKTIME_Sec
    ,hour(Total_Login_Hours) * 3600 + minute(Total_Login_Hours) * 60 + second(Total_Login_Hours) as Login_Hours_sec 
    ,hour(Ready) * 3600 + minute(Ready) * 60 + second(Ready) as Ready_sec
    ,hour(Callback) * 3600 + minute(Callback) * 60 + second(Callback) as Callback_sec
    ,hour(Stop) * 3600 + minute(Stop) * 60 + second(Stop) as Stop_sec
    ,hour(CallSetup_Offer) * 3600 + minute(CallSetup_Offer) * 60 + second(CallSetup_Offer) as CallSetup_Offer_Sec
    ,hour(Pause) * 3600 + minute(Pause) * 60 + second(Pause) as Pause_Sec
    ,hour(Ringing) * 3600 + minute(Ringing) * 60 + second(Ringing) as Ringing_Sec
    ,hour(Dispose) * 3600 + minute(Dispose) * 60 + second(Dispose) as Dispose_Sec
    ,hour(Login_Time) * 3600 + minute(Login_Time) * 60 + second(Login_Time) as Login_Time_Sec

FROM id_temp.Agent_summary1)

-- COMMAND ----------

select login_status,Business_Date,TIME_SLOT,count(*) from  id_temp.Agent_Report_Summary group by login_status,Business_Date,TIME_SLOT

-- COMMAND ----------


CREATE or replace table id_temp.login3 as 
(
   SELECT *,
    CASE 
        WHEN left(User_Name, 1) IN ('0', '2', '3', '4', '5', '6', '7', '8', '9') 
        THEN 
            regexp_extract(User_Name, '([0-9]+)', 0)
        ELSE 
            regexp_extract(User_Name, '([0-9]+)', 0)
    END AS Employe_Id
    FROM id_temp.login2
)

-- COMMAND ----------

CREATE or replace table id_temp.PSF_login_logout_Details as
(

SELECT 
    *,
    CASE 
        WHEN hour(login_time) < 10 THEN 'A.10AM'
        WHEN hour(login_time) < 12 THEN 'B.10_12PM'
        WHEN hour(login_time) < 15 THEN 'C.12_15PM'
        WHEN hour(login_time) < 18 THEN 'D.15_18PM'
        ELSE 'E.ALL_EOD'
    END AS TIME_SLOT,

    CASE 
        WHEN hour(logout_time) < 10 THEN 'A.10AM'
        WHEN hour(logout_time) < 12 THEN 'B.10_12PM'
        WHEN hour(logout_time) < 15 THEN 'C.12_15PM'
        WHEN hour(logout_time) < 18 THEN 'D.15_18PM'
        ELSE 'E.ALL_EOD'
    END AS TIME_SLOT1,

    CASE 
        WHEN Employe_Id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS Login_status,

unix_timestamp(cast(logout_time as timestamp)) - unix_timestamp(cast(login_time as timestamp)) AS DIFFRANCE, -- Difference in seconds

    cast(date_sub(current_date(), 1) AS date) AS Date_Time,  -- Backdated data added
    last_day(current_date()) AS Business_Date 

FROM id_temp.login3
)

-- COMMAND ----------

CREATE OR REPLACE TABLE id_temp.Agent_Report_Final2
 AS (
Select a.*,SM,Deputy_ASM,ASM,RSM,ZSM,ZONE,NSM,Location,LOB
 from id_temp.Agent_Report_Summary A
Left join bfl_std_lake.insurance_distribution.psf_master_jan_25 B
on A.Employe_Id =  Replace(B.EMPLOYEE,'QS','') )

-- COMMAND ----------

CREATE OR REPLACE TABLE id_temp.Agent_Report_Final
(
SELECT DISTINCT 
    Name,
    Username,
    Ready,
    Manual,
    Preview,
    Callback,
    Stop,
    CallSetup_Offer,
    Pause,
    Headset_Test,
    Ringing,
    Talktime,
    Mute,
    Hold,
    Transfer,
    Conference,
    Dispose,
    Call_Time,
    Handling_Time,
    Login_Time,
    Total_Login_Hours,
    Total_Calls,
    Outbound_Calls,
    Inbound_Calls,
    (Answered_Calls - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Answered_CallsNEW, 0) 
        END)) AS Answered_Calls_NET,
    Outbound_Answered_Calls,
    Inbound_Answered_Calls,
    Not_Answered_Calls,
    Total_TalkTime,
    Outbound_TalkTime,
    Inbound_TalkTime,
    Average_TalkTime,
    Average_TalkTime_Outbound,
    Average_TalkTime_Inbound,
    Average_HandlingTime,
    Average_Handling_Outbound,
    Average_Handling_Inbound,
    SAP_ID,
    Email,
    Briefing_pause,
    tea_break_pause,
    lunch_pause,
    other_pause,
    verification_pause,
    Training_pause,
    Meeting_pause,
    Utility_pause,
    Date, 
    business_date,
    a.TIME_SLOT,
    (CASE 
        WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 'LOGIN' 
        WHEN A.TIME_SLOT = B.TIME_SLOT THEN 'LOGIN' 
        ELSE 'NOT_LOGIN' 
    END) AS LOGIN_STATUS,
    a.Employe_id,
    (TALKTIME_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(TALKTIME_SecNEW, 0) 
        END)) AS TALKTIME_Sec_NET,
    (Login_Hours_sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Login_Hours_secNEW, 0) 
        END)) AS Login_Hours_sec_NET,
    (Ready_sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Ready_secNEW, 0) 
        END)) AS Ready_sec_NET,
    (Callback_sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Callback_secNEW, 0) 
        END)) AS Callback_sec_NET,
    (Stop_sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Stop_secNEW, 0) 
        END)) AS Stop_sec_NET,
    (CallSetup_Offer_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(CallSetup_Offer_SecNEW, 0) 
        END)) AS CallSetup_Offer_Sec_NET,
    (Pause_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Pause_SecNEW, 0) 
        END)) AS Pause_Sec_NET,
    (Ringing_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Ringing_SecNEW, 0) 
        END)) AS Ringing_Sec_NET,
    (Dispose_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Dispose_SecNEW, 0) 
        END)) AS Dispose_Sec_NET,
    (Login_Time_Sec - 
        (CASE 
            WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 0 
            ELSE COALESCE(Login_Time_SecNEW, 0) 
        END)) AS Login_Time_Sec_NET,
    SM,
    Deputy_ASM,
    ASM,
    RSM,
    ZSM,
    ZONE,
    NSM,
    Location,
    LOB
FROM 
    id_temp.Agent_Report_Final2 A
LEFT JOIN 
    (SELECT  
        employe_id,
        (CASE 
            WHEN LEFT(TIME_SLOT, 1) > LEFT(TIME_SLOT1, 1) THEN TIME_SLOT 
            WHEN LEFT(TIME_SLOT1, 1) > LEFT(TIME_SLOT, 1) THEN TIME_SLOT1 
            ELSE TIME_SLOT 
        END) AS TIME_SLOT, 
        SUM(Diffrance) AS login_hrs,
        MAX(logout_Time) AS logout_Time
     FROM 
        id_temp.PSF_login_logout_Details
     GROUP BY 
        employe_id, 
        (CASE 
            WHEN LEFT(TIME_SLOT, 1) > LEFT(TIME_SLOT1, 1) THEN TIME_SLOT 
            WHEN LEFT(TIME_SLOT1, 1) > LEFT(TIME_SLOT, 1) THEN TIME_SLOT1 
            ELSE TIME_SLOT 
        END)
    ) B
    ON A.Employe_id = B.Employe_id  
    AND A.TIME_SLOT = B.TIME_SLOT 
LEFT JOIN 
    (SELECT 
        Employe_id,
        SUM(COALESCE(TALKTIME_Sec, 0)) AS TALKTIME_SecNEW,
        SUM(COALESCE(Login_Hours_sec, 0)) AS Login_Hours_secNEW,
        SUM(COALESCE(Ready_sec, 0)) AS Ready_secNEW,
        SUM(COALESCE(Callback_sec, 0)) AS Callback_secNEW,
        SUM(COALESCE(Stop_sec, 0)) AS Stop_secNEW,
        SUM(COALESCE(CallSetup_Offer_Sec, 0)) AS CallSetup_Offer_SecNEW,
        SUM(COALESCE(Pause_Sec, 0)) AS Pause_SecNEW,
        SUM(COALESCE(Ringing_Sec, 0)) AS Ringing_SecNEW,
        SUM(COALESCE(Dispose_Sec, 0)) AS Dispose_SecNEW,
        SUM(COALESCE(Login_Time_Sec, 0)) AS Login_Time_SecNEW,
        SUM(COALESCE(CAST(Answered_Calls AS NUMERIC), 0)) AS Answered_CallsNEW
     FROM 
        bfl_std_lake.insurance_distribution.agent_report_final_master
     WHERE 
        CAST(date_time AS DATE) = date_sub(current_date(), 1)------Back Dated Data
        AND CAST(business_date AS DATE) = last_day(current_date())
     GROUP BY 
        Employe_id
    ) V
    ON A.Employe_id = V.Employe_id  
WHERE 
    (CASE 
        WHEN A.TIME_SLOT = 'E.ALL_EOD' THEN 'LOGIN' 
        WHEN A.TIME_SLOT = B.TIME_SLOT THEN 'LOGIN' 
        ELSE 'NOT_LOGIN' 
    END) = 'LOGIN')

-- COMMAND ----------


Insert Into id_temp.Agent_Report_Final
(Name,Username,Employe_id,SM,Deputy_ASM,ASM,RSM,ZSM,ZONE,NSM,Location,LOB,Date,Business_Date,TIME_SLOT,LOGIN_STATUS) 
SELECT 
    Inpreview_Mode_Process,
    UserID_Auto_Process,
    employee,
    SM,
    Deputy_ASM,
    ASM,
    RSM,
    ZSM,
    ZONE,
    NSM,
    Location,
    LOB,
    CAST(date_sub(current_date(), 1) AS DATE) AS Date_Time, -- back dated data added so change the number(1)
    LAST_DAY(current_date()) AS Business_Date,
    CASE
        WHEN hour(cast(current_timestamp() AS timestamp)) > 9 
            AND hour(cast(current_timestamp() AS timestamp)) < 20 THEN 'E.ALL_EOD'
        ELSE 'E.ALL_EOD' 
    END AS TIME_SLOT,
    CASE 
        WHEN Inpreview_Mode_Process IS NOT NULL THEN 'NOT_LOGIN' 
        ELSE '' 
    END AS LOGIN_STATUS
FROM 
    bfl_std_lake.insurance_distribution.psf_master_jan_25 B
WHERE 
    NOT EXISTS (
        SELECT 1 FROM id_temp.Agent_Report_Final C WHERE C.Username = B.UserID_Auto_Process)
        ;

-- COMMAND ----------


select * from id_temp.Agent_Report_Final limit 10

-- COMMAND ----------


UPDATE id_temp.Agent_Report_Final
 SET date = CAST(date_sub(current_date(), 1) AS DATE); ----- Back Dated Data need to changed as per requirement

-- COMMAND ----------


INSERT INTO bfl_std_lake.insurance_distribution.agent_report_final_master
SELECT * 
FROM id_temp.Agent_Report_Final b
WHERE NOT EXISTS (
    SELECT 1 
    FROM bfl_std_lake.insurance_distribution.agent_report_final_master c
    WHERE c.Username = b.Username AND b.date = c.date_time 
    AND b.TIME_SLOT = c.TIME_SLOT
);

-- COMMAND ----------


UPDATE bfl_std_lake.insurance_distribution.agent_report_final_master
SET Name = 
   CASE 
       WHEN LEFT(Name, 1) IN ('0','2','3','4','5','6','7','8','9') 
       THEN SUBSTRING(Name, REGEXP_INSTR(Name, '[A-Z]'), LENGTH(Name) - REGEXP_INSTR(Name, '[A-Z]') + 1)
       ELSE SUBSTRING(Name, REGEXP_INSTR(Name, '[A-Z]'), LENGTH(Name))
   END
WHERE date_time = CAST(DATE_SUB(CURRENT_DATE(),  1) AS DATE); --back Dated

-- COMMAND ----------

select * from bfl_std_lake.insurance_distribution.agent_report_final_master where date_time= CAST(date_sub(current_date(), 1) AS DATE)

-- COMMAND ----------


 /*delete from bfl_std_lake.insurance_distribution.agent_report_final_master 
 where 
     TIME_SLOT = 'E.ALL_EOD' 
 and business_date = '2025-03-31' 
 and date_time  = '2025-03-16';
 --select * from id_temp.Agent_Report_Final where TIME_SLOT = 'E.ALL_EOD' and business_date = '2025-03-31' and Date = '2025-03-02'
*/

-- COMMAND ----------

/*update bfl_std_lake.insurance_distribution.agent_report_final_master 
set business_date = '2025-03-31'
where 
     TIME_SLOT = 'E.ALL_EOD' 
 and date_time  = '2025-03-31';*/

-- COMMAND ----------

/*delete from bfl_std_lake.insurance_distribution.agent_report_final_master 
 where 
  business_date = '2024-07-31' */