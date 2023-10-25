CREATE OR REPLACE PROCEDURE DW_DEV.HAH.MERGE_STAGE_ASR_DIM_CONTRACT()
RETURNS VARCHAR(16777216)
LANGUAGE JAVASCRIPT
EXECUTE AS OWNER
AS '

    var sqlCmd = "";
    var sqlStmt = "";
    var result = "";

    try {
      var sqlCmd = `
    MERGE INTO HAH.DIM_CONTRACT TGT 
USING STAGE.ASR_DIM_CONTRACT STAGE 
ON TGT.CONTRACT_KEY = STAGE.CONTRACT_KEY
WHEN MATCHED THEN 
UPDATE SET 
    TGT.CONTRACT_CODE= STAGE.CONTRACT_CODE
   ,TGT.SYSTEM_CODE= STAGE.SYSTEM_CODE
   ,TGT.SOURCE_SYSTEM_ID= STAGE.SOURCE_SYSTEM_ID
   ,TGT.CONTRACT_NAME= STAGE.CONTRACT_NAME
   ,TGT.SERVICE_CODE_ID= STAGE.SERVICE_CODE_ID
   ,TGT.SERVICE_KEY= STAGE.SERVICE_KEY
   ,TGT.DEFAULT_BILL_CODE= STAGE.DEFAULT_BILL_CODE
--   ,TGT.CONTRACT_BILL_CODE= STAGE.CONTRACT_BILL_CODE
   ,TGT.PAYROLL_CODE= STAGE.PAYROLL_CODE
   ,TGT.REVENUE_CATEGORY= STAGE.REVENUE_CATEGORY
   ,TGT.REVENUE_SUBCATEGORY_CODE= STAGE.REVENUE_SUBCATEGORY_CODE
   ,TGT.REVENUE_SUBCATEGORY_NAME= STAGE.REVENUE_SUBCATEGORY_NAME
   ,TGT.PAYOR_CODE= STAGE.PAYOR_CODE
   ,TGT.PAYOR_DESCRIPTION= STAGE.PAYOR_DESCRIPTION
   ,TGT.SERVICE_LINE_CODE= STAGE.SERVICE_LINE_CODE
   ,TGT.SERVICE_LINE_DESCRIPTION= STAGE.SERVICE_LINE_DESCRIPTION
   ,TGT.CONTRACT_STATE_CODE= STAGE.CONTRACT_STATE_CODE
   ,TGT.TIME_TRANSLATION_CODE= STAGE.TIME_TRANSLATION_CODE
   ,TGT.TIME_TRANSLATION_DIVIDER= STAGE.TIME_TRANSLATION_DIVIDER
   ,TGT.PAY_TRAVELS_CODE= STAGE.PAY_TRAVELS_CODE
   ,TGT.MILEAGE_FLAG= STAGE.MILEAGE_FLAG
   ,TGT.PAYABLE_FLAG= STAGE.PAYABLE_FLAG
   ,TGT.BILLABLE_FLAG= STAGE.BILLABLE_FLAG
   ,TGT.BILLED_BY_QUARTER_HOURS= STAGE.BILLED_BY_QUARTER_HOURS
   ,TGT.BILLED_BY_HALF_HOURS= STAGE.BILLED_BY_HALF_HOURS
   ,TGT.EFFECTIVE_FROM_DATE= STAGE.EFFECTIVE_FROM_DATE
   ,TGT.EFFECTIVE_TO_DATE= STAGE.EFFECTIVE_TO_DATE
   ,TGT.ETL_TASK_KEY= STAGE.ETL_TASK_KEY
   ,TGT.ETL_LAST_UPDATED_DATE= STAGE.ETL_LAST_UPDATED_DATE
   ,TGT.ETL_LAST_UPDATED_BY= STAGE.ETL_LAST_UPDATED_BY
   ,TGT.ETL_DELETED_FLAG= STAGE.ETL_DELETED_FLAG
   ,TGT.ETL_INFERRED_MEMBER_FLAG= STAGE.ETL_INFERRED_MEMBER_FLAG
WHEN NOT MATCHED THEN 
INSERT ( 
    CONTRACT_KEY
   ,CONTRACT_CODE
   ,SYSTEM_CODE
   ,SOURCE_SYSTEM_ID
   ,CONTRACT_NAME
   ,SERVICE_CODE_ID
   ,SERVICE_KEY
   ,DEFAULT_BILL_CODE
 --  ,CONTRACT_BILL_CODE
   ,PAYROLL_CODE
   ,REVENUE_CATEGORY
   ,REVENUE_SUBCATEGORY_CODE
   ,REVENUE_SUBCATEGORY_NAME
   ,PAYOR_CODE
   ,PAYOR_DESCRIPTION
   ,SERVICE_LINE_CODE
   ,SERVICE_LINE_DESCRIPTION
   ,CONTRACT_STATE_CODE
   ,TIME_TRANSLATION_CODE
   ,TIME_TRANSLATION_DIVIDER
   ,PAY_TRAVELS_CODE
   ,MILEAGE_FLAG
   ,PAYABLE_FLAG
   ,BILLABLE_FLAG
   ,BILLED_BY_QUARTER_HOURS
   ,BILLED_BY_HALF_HOURS
   ,EFFECTIVE_FROM_DATE
   ,EFFECTIVE_TO_DATE
   ,ETL_TASK_KEY
   ,ETL_INSERTED_TASK_KEY
   ,ETL_INSERTED_DATE
   ,ETL_INSERTED_BY
   ,ETL_LAST_UPDATED_DATE
   ,ETL_LAST_UPDATED_BY
   ,ETL_DELETED_FLAG
   ,ETL_INFERRED_MEMBER_FLAG
) 
VALUES (
    STAGE.CONTRACT_KEY
   ,STAGE.CONTRACT_CODE
   ,STAGE.SYSTEM_CODE
   ,STAGE.SOURCE_SYSTEM_ID
   ,STAGE.CONTRACT_NAME
   ,STAGE.SERVICE_CODE_ID
   ,STAGE.SERVICE_KEY
   ,STAGE.DEFAULT_BILL_CODE
--   ,STAGE.CONTRACT_BILL_CODE
   ,STAGE.PAYROLL_CODE
   ,STAGE.REVENUE_CATEGORY
   ,STAGE.REVENUE_SUBCATEGORY_CODE
   ,STAGE.REVENUE_SUBCATEGORY_NAME
   ,STAGE.PAYOR_CODE
   ,STAGE.PAYOR_DESCRIPTION
   ,STAGE.SERVICE_LINE_CODE
   ,STAGE.SERVICE_LINE_DESCRIPTION
   ,STAGE.CONTRACT_STATE_CODE
   ,STAGE.TIME_TRANSLATION_CODE
   ,STAGE.TIME_TRANSLATION_DIVIDER
   ,STAGE.PAY_TRAVELS_CODE
   ,STAGE.MILEAGE_FLAG
   ,STAGE.PAYABLE_FLAG
   ,STAGE.BILLABLE_FLAG
   ,STAGE.BILLED_BY_QUARTER_HOURS
   ,STAGE.BILLED_BY_HALF_HOURS
   ,STAGE.EFFECTIVE_FROM_DATE
   ,STAGE.EFFECTIVE_TO_DATE
   ,STAGE.ETL_TASK_KEY
   ,STAGE.ETL_INSERTED_TASK_KEY
   ,STAGE.ETL_INSERTED_DATE
   ,STAGE.ETL_INSERTED_BY
   ,STAGE.ETL_LAST_UPDATED_DATE
   ,STAGE.ETL_LAST_UPDATED_BY
   ,STAGE.ETL_DELETED_FLAG
   ,STAGE.ETL_INFERRED_MEMBER_FLAG
)

    `;
      sqlStmt = snowflake.createStatement( {sqlText: sqlCmd} );
      rs = sqlStmt.execute();
      sqlCmd = 
            `SELECT "number of rows inserted", "number of rows updated"
              FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))`;
      sqlStmt = snowflake.createStatement( {sqlText: sqlCmd} );
      rs = sqlStmt.execute();
          rs.next();
          result += ''{"Inserted": "'' + rs.getColumnValue(1) + ''", "Updated": "'' + rs.getColumnValue(2) +''", "ErrorCode":"NA", "ErrorState":"NA", "ErrorMessage":"NA", "ErrorStackTrace":"NA"}'';
    }
    catch (err) {
        result = ''{"Inserted": "0", "Updated": "0", "ErrorCode":"''+ err.code +''", "ErrorState":"''+ err.state +''", "ErrorMessage":"''+ err.message +''", "ErrorStackTrace":"''+ err.stackTraceTxt +''"}'';
    }
    return result;
    ';