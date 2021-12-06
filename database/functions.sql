DROP TYPE GET_TAB_DESIASE;
DROP TYPE GET_ROW_DESIASE;
CREATE TYPE CREATOR.GET_ROW_DESIASE AS OBJECT(
    US_FULLNAME  NVARCHAR2(50),
    DOC_FULLNAME NVARCHAR2(50),
    DT_VISITE    DATE,
    SYMPTOMES    NVARCHAR2(200),
    THERAPY      NVARCHAR2(200),
    RES_DES      NVARCHAR2(200)
);
CREATE TYPE CREATOR.GET_TAB_DESIASE IS TABLE OF GET_ROW_DESIASE;
DROP FUNCTION GET_HIST_BYID;
---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION CREATOR.GET_HIST_BYID (ID_USER USER_.ID_USER%TYPE) RETURN GET_TAB_DESIASE PIPELINED 
IS
CURSOR GET_HIST_CURS (ID_USER_ USER_.ID_USER%TYPE) is 
SELECT USER_.FULLNAME, DOCTOR.FULL_NAME, HEALTH.DATE_TIME_VISITE, 
    DESIASE.SYMPTOMES, DESIASE.THERAPY, DESIASE.RESULT_DESIASE 
    FROM HEALTH JOIN DESIASE ON DESIASE.ID_VISITE = HEALTH.ID_VISITE
    JOIN USER_ ON HEALTH.ID_USER = USER_.ID_USER
    JOIN DOCTOR ON HEALTH.ID_DOCTOR = DOCTOR.ID_DOCTOR
    WHERE USER_.ID_USER = ID_USER_;  
BEGIN
    FOR SEARCH_TAB IN GET_HIST_CURS(ID_USER)
    LOOP
        PIPE ROW(GET_ROW_DESIASE
        (
        SEARCH_TAB.FULLNAME, 
        SEARCH_TAB.FULL_NAME, SEARCH_TAB.DATE_TIME_VISITE,
        SEARCH_TAB.SYMPTOMES, SEARCH_TAB.THERAPY, SEARCH_TAB.RESULT_DESIASE
        ));
    END LOOP;
    RETURN;
END;
--//dbms_crypto
--//dbms_маскирование
---------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION CREATOR.GET_HIST_BY_FULLNAME (FULLNAME USER_.FULLNAME%TYPE) RETURN GET_TAB_DESIASE PIPELINED 
IS
CURSOR GET_HIST_CURS (FULLNAME_ USER_.FULLNAME%TYPE) is 
SELECT USER_.FULLNAME, DOCTOR.FULL_NAME, HEALTH.DATE_TIME_VISITE, 
    DESIASE.SYMPTOMES, DESIASE.THERAPY, DESIASE.RESULT_DESIASE 
    FROM HEALTH 
    JOIN DESIASE ON DESIASE.ID_VISITE = HEALTH.ID_VISITE
    JOIN USER_ ON HEALTH.ID_USER = USER_.ID_USER
    JOIN DOCTOR ON HEALTH.ID_DOCTOR = DOCTOR.ID_DOCTOR
    WHERE USER_.FULLNAME LIKE('%' || FULLNAME || '%');  
BEGIN
    FOR SEARCH_TAB IN GET_HIST_CURS(FULLNAME)
    LOOP
        PIPE ROW(GET_ROW_DESIASE
        (
        SEARCH_TAB.FULLNAME, 
        SEARCH_TAB.FULL_NAME, SEARCH_TAB.DATE_TIME_VISITE,
        SEARCH_TAB.SYMPTOMES, SEARCH_TAB.THERAPY, SEARCH_TAB.RESULT_DESIASE
        ));
    END LOOP;
    RETURN;
END;



DROP FUNCTION GET_HIST_BY_FULLNAME;
CREATE OR REPLACE FUNCTION CREATOR.GET_HIST_BY_FULLNAME (FULLNAME_ USER_.FULLNAME%TYPE) RETURN SYS_REFCURSOR
IS
    HIST_CURS SYS_REFCURSOR;
    USER_NAME USER_.FULLNAME%TYPE := FULLNAME_;
BEGIN
    OPEN HIST_CURS FOR 
    Q'[SELECT USER_.FULLNAME, DOCTOR.FULL_NAME, HEALTH.DATE_TIME_VISITE, 
    DESIASE.SYMPTOMES, DESIASE.THERAPY, DESIASE.RESULT_DESIASE 
    FROM HEALTH 
    JOIN DESIASE ON DESIASE.ID_VISITE = HEALTH.ID_VISITE
    JOIN USER_ ON HEALTH.ID_USER = USER_.ID_USER
    JOIN DOCTOR ON HEALTH.ID_DOCTOR = DOCTOR.ID_DOCTOR
    WHERE USER_.FULLNAME LIKE('%' || USER_NAME || '%')]';  
    RETURN HIST_CURS;
END;

