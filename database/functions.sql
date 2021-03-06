---------------------------------------------------------------------------------------------------------------
------------------------------ DOC_PACKAGE ----------------------------------------------------------------


CREATE OR REPLACE PACKAGE USERS_FUNCTION IS

PROCEDURE GET_HIST_BYID (ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2);

PROCEDURE GET_ANALYSES_BY_ID_USER(ID_ANALYSE ANALYSES.ID_ANALYSE%TYPE, ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2);

PROCEDURE GET_HOME_ANALYSES_BY_ID(ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2);

END USERS_FUNCTION;

CREATE PACKAGE BODY USERS_FUNCTION IS

    PROCEDURE GET_HIST_BYID (ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2)
    IS
    CURSOR GET_HIST_CURS (ID_USER_ USER_.ID_USER%TYPE) is 
    SELECT USER_.FULLNAME, DOCTOR.FULL_NAME, HEALTH.DATE_TIME_VISITE, 
        DESIASE.SYMPTOMES, DESIASE.THERAPY, DESIASE.RESULT_DESIASE 
        FROM HEALTH JOIN DESIASE ON DESIASE.ID_VISITE = HEALTH.ID_VISITE
        JOIN USER_ ON HEALTH.ID_USER = USER_.ID_USER
        JOIN DOCTOR ON HEALTH.ID_DOCTOR = DOCTOR.ID_DOCTOR
        WHERE USER_.ID_USER = ID_USER_;  
    GET_HIST_VAL GET_HIST_CURS%ROWTYPE;
    RES VARCHAR2(3000) := '';
    BEGIN
        FOR GET_HIST_VAL IN GET_HIST_CURS(ID_USER)
        LOOP
            RES:= CONCAT(RES, (GET_HIST_VAL.FULLNAME || ' ' ||GET_HIST_VAL.FULL_NAME || ' ' ||GET_HIST_VAL.DATE_TIME_VISITE ||
            ' ' ||GET_HIST_VAL.SYMPTOMES || ' ' ||GET_HIST_VAL.THERAPY || ' ' ||GET_HIST_VAL.RESULT_DESIASE || CHR(13)));
        END LOOP;
        RES_ := RES;
        RETURN;
    END GET_HIST_BYID;

    PROCEDURE GET_ANALYSES_BY_ID_USER(ID_ANALYSE ANALYSES.ID_ANALYSE%TYPE,
        ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2)
    IS
        CURSOR GET_ANALYSES(ID_ANALYSE_ ANALYSES.ID_ANALYSE%TYPE, ID_USER_ USER_.ID_USER%TYPE) IS
        SELECT ANALYSES.LABARATORY, ANALYSES.NAME_ANALYSE, ANALYSES.RESULT_ANALYSE, DATE_TIME_ANALYSE 
        FROM ANALYSES JOIN HEALTH ON 
        ANALYSES.ID_VISITE = HEALTH.ID_VISITE
        WHERE ANALYSES.ID_ANALYSE = ID_ANALYSE_ AND HEALTH.ID_USER = ID_USER_ ;
        RES VARCHAR2(3000);
        GET_ANALYSE GET_ANALYSES%ROWTYPE;
    BEGIN
        FOR GET_ANALYSE IN GET_ANALYSES(ID_ANALYSE, ID_USER)
        LOOP
            RES:= CONCAT(RES, (GET_ANALYSE.LABARATORY || ' ' ||GET_ANALYSE.NAME_ANALYSE || ' ' ||GET_ANALYSE.RESULT_ANALYSE||
            ' ' ||GET_ANALYSE.DATE_TIME_ANALYSE || CHR(13)));
        END LOOP;
        RES_:=RES;
    END GET_ANALYSES_BY_ID_USER;

    PROCEDURE GET_HOME_ANALYSES_BY_ID(ID_USER USER_.ID_USER%TYPE, RES_ OUT VARCHAR2)
    IS
        CURSOR GET_ALL_USER_ANALYSES (ID_USER_ USER_.ID_USER%TYPE) IS
        SELECT USER_.FULLNAME, 
        DECRYPTOR_VALUE_128(HOME_ANALYSES.PULSE) PULSE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.TEMPERATURE) TEMPERATURE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.BLOOD_PRESS) BLOOD_PRESS,
        HOME_ANALYSES.DATE_ANALYSE
        FROM HOME_ANALYSES JOIN USER_
        ON USER_.ID_USER = HOME_ANALYSES.ID_USER
        WHERE HOME_ANALYSES.ID_USER = ID_USER_;
        RES VARCHAR2(3000);
        GET_ANALYSE GET_ALL_USER_ANALYSES%ROWTYPE;
    BEGIN
        FOR SEARCH_TAB IN GET_ALL_USER_ANALYSES(ID_USER)
        LOOP
        RES:= CONCAT(RES, (GET_ANALYSE.FULLNAME || ' ' ||GET_ANALYSE.PULSE || ' ' ||GET_ANALYSE.TEMPERATURE ||
            ' ' ||GET_ANALYSE.BLOOD_PRESS || ' ' || GET_ANALYSE.DATE_ANALYSE || CHR(13)));
        END LOOP;
        RES_:=RES;
        RETURN;
    END GET_HOME_ANALYSES_BY_ID;

END USERS_FUNCTION;
---------------------------------------------------------------------------------------------------------------
------------------------------ USER PACKAGE ----------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------
------------------------------ DOC_PACKAGE ----------------------------------------------------------------


CREATE OR REPLACE PACKAGE DOC_FUNCTIONS IS

FUNCTION GET_HIST_BYID (ID_USER USER_.ID_USER%TYPE)
RETURN GET_TAB_DESIASE PIPELINED;

FUNCTION GET_HIST_BY_FULLNAME (FULLNAME USER_.FULLNAME%TYPE)
RETURN GET_TAB_DESIASE PIPELINED;

FUNCTION GET_ANALYSES_BY_ID_DOC(ID_ANALYSE ANALYSES.ID_ANALYSE%TYPE)
RETURN GET_TAB_ANALYSES PIPELINED;

FUNCTION GET_HOME_ANALYSES_BY_ID(ID_USER USER_.ID_USER%TYPE) --USER, DOC
RETURN GET_TAB_HOME_ANALYSE PIPELINED;

FUNCTION GET_HOME_ANALYSES_BY_FULLNAME(NAME_USER USER_.FULLNAME%TYPE) --DOC
RETURN GET_TAB_HOME_ANALYSE PIPELINED;

END DOC_FUNCTIONS;

CREATE OR REPLACE PACKAGE BODY DOC_FUNCTIONS IS

    FUNCTION GET_HIST_BYID (ID_USER USER_.ID_USER%TYPE) RETURN GET_TAB_DESIASE PIPELINED 
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
    END GET_HIST_BYID;

    FUNCTION GET_HIST_BY_FULLNAME (FULLNAME USER_.FULLNAME%TYPE) RETURN GET_TAB_DESIASE PIPELINED 
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
    END GET_HIST_BY_FULLNAME;

    FUNCTION GET_ANALYSES_BY_ID_DOC(ID_ANALYSE ANALYSES.ID_ANALYSE%TYPE)
    RETURN GET_TAB_ANALYSES PIPELINED
    IS
        CURSOR GET_ANALYSES (ID_ANALYSE_ ANALYSES.ID_ANALYSE%TYPE) IS 
        SELECT LABARATORY, NAME_ANALYSE, RESULT_ANALYSE, DATE_TIME_ANALYSE FROM
        ANALYSES WHERE ANALYSES.ID_ANALYSE = ID_ANALYSE_;
    BEGIN
        FOR SEARCH_TAB IN GET_ANALYSES(ID_ANALYSE)
        LOOP
            PIPE ROW(GET_ROW_ANALYSES
            (
            SEARCH_TAB.LABARATORY, 
            SEARCH_TAB.NAME_ANALYSE,
            SEARCH_TAB.RESULT_ANALYSE,
            SEARCH_TAB.DATE_TIME_ANALYSE
            ));
        END LOOP;
        RETURN;
    END GET_ANALYSES_BY_ID_DOC;

    FUNCTION GET_HOME_ANALYSES_BY_ID(ID_USER USER_.ID_USER%TYPE) --USER, DOC
    RETURN GET_TAB_HOME_ANALYSE PIPELINED
    IS
        CURSOR GET_ALL_USER_ANALYSES (ID_USER_ USER_.ID_USER%TYPE) IS
        SELECT USER_.FULLNAME, 
        DECRYPTOR_VALUE_128(HOME_ANALYSES.PULSE) PULSE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.TEMPERATURE) TEMPERATURE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.BLOOD_PRESS) BLOOD_PRESS,
        HOME_ANALYSES.DATE_ANALYSE
        FROM HOME_ANALYSES JOIN USER_
        ON USER_.ID_USER = HOME_ANALYSES.ID_USER
        WHERE HOME_ANALYSES.ID_USER = ID_USER_;
    BEGIN
        FOR SEARCH_TAB IN GET_ALL_USER_ANALYSES(ID_USER)
        LOOP
        PIPE ROW(GET_ROW_HOME_ANALYSE
        (
        SEARCH_TAB.FULLNAME,
        SEARCH_TAB.PULSE,
        SEARCH_TAB.TEMPERATURE,
        SEARCH_TAB.BLOOD_PRESS,
        SEARCH_TAB.DATE_ANALYSE
        ));
        END LOOP;
        RETURN;
    END GET_HOME_ANALYSES_BY_ID;
    
    FUNCTION GET_HOME_ANALYSES_BY_FULLNAME(NAME_USER USER_.FULLNAME%TYPE) --DOC
    RETURN GET_TAB_HOME_ANALYSE PIPELINED
    IS
        CURSOR GET_ALL_USER_ANALYSES (NAME_USER_ USER_.FULLNAME%TYPE) IS
        SELECT USER_.FULLNAME, 
        DECRYPTOR_VALUE_128(HOME_ANALYSES.PULSE) PULSE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.TEMPERATURE) TEMPERATURE,
        DECRYPTOR_VALUE_128(HOME_ANALYSES.BLOOD_PRESS) BLOOD_PRESS,
        HOME_ANALYSES.DATE_ANALYSE
        FROM HOME_ANALYSES JOIN USER_
        ON USER_.ID_USER = HOME_ANALYSES.ID_USER
        WHERE USER_.FULLNAME  LIKE('%' || NAME_USER || '%');
    BEGIN
        FOR SEARCH_TAB IN GET_ALL_USER_ANALYSES(NAME_USER)
        LOOP
        PIPE ROW(GET_ROW_HOME_ANALYSE
        (
        SEARCH_TAB.FULLNAME,
        SEARCH_TAB.PULSE,
        SEARCH_TAB.TEMPERATURE,
        SEARCH_TAB.BLOOD_PRESS,
        SEARCH_TAB.DATE_ANALYSE
        ));
        END LOOP;
        RETURN;
    END GET_HOME_ANALYSES_BY_FULLNAME;

END DOC_FUNCTIONS;
---------------------------------------------------------------------------------------------------------------
------------------------------ DOC_PACKAGE ----------------------------------------------------------------



---------------------------------------------------------------------------------------------------------------
------------------------------CRYPTO FUNCTIONS ----------------------------------------------------------------



DROP FUNCTION CREATOR.CRYPTO_VALUE_128;
CREATE OR REPLACE FUNCTION CREATOR.CRYPTO_VALUE_128 (BEFORE_ IN VARCHAR2) RETURN VARCHAR2
IS
 L_ENC_VAL RAW(200);
 L_KEY VARCHAR2(128):='QHOXvJyLaNTIOdHr';
 L_MOD NUMBER := DBMS_CRYPTO.encrypt_aes128
              + DBMS_CRYPTO.chain_cbc
              + DBMS_CRYPTO.pad_pkcs5;
BEGIN
    L_ENC_VAL := DBMS_CRYPTO.encrypt(utl_i18n.string_to_raw(BEFORE_, 'AL32UTF8'),
                                    L_MOD,
                                    utl_i18n.string_to_raw(L_KEY, 'AL32UTF8')
                                    );
    RETURN L_ENC_VAL;
END;

DROP FUNCTION CREATOR.DECRYPTOR_VALUE_128;
CREATE OR REPLACE FUNCTION CREATOR.DECRYPTOR_VALUE_128 (BEFORE_ IN VARCHAR2) RETURN VARCHAR2
IS
    L_KEY VARCHAR2(128):='QHOXvJyLaNTIOdHr';
    L_DEC RAW(200);
    L_MOD NUMBER := DBMS_CRYPTO.encrypt_aes128
    + DBMS_CRYPTO.chain_cbc
    + DBMS_CRYPTO.pad_pkcs5;
BEGIN
    L_DEC := DBMS_CRYPTO.decrypt(BEFORE_,
                                L_MOD,
                                utl_i18n.string_to_raw(L_KEY, 'AL32UTF8')
                                );
    RETURN utl_i18n.raw_to_char(L_DEC);
END;

DROP FUNCTION CREATOR.CRYPTO_VALUE_192;
CREATE OR REPLACE FUNCTION CREATOR.CRYPTO_VALUE_192 (BEFORE_ IN VARCHAR2) RETURN VARCHAR2
IS
    L_ENC_VAL RAW(4000);
    L_KEY VARCHAR(192):='jySkWpyFLsbforZvlErpszVh';
BEGIN
    L_ENC_VAL := DBMS_CRYPTO.encrypt(src => utl_i18n.string_to_raw(BEFORE_, 'AL32UTF8'),
                                    key => utl_i18n.string_to_raw(L_KEY, 'AL32UTF8'),
                                    typ => DBMS_CRYPTO.encrypt_aes192 + DBMS_CRYPTO.chain_cbc + DBMS_CRYPTO.pad_pkcs5);
    RETURN L_ENC_VAL;
END;


