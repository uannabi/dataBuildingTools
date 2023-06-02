-- dbt_project/models/set_interest_type.sql

WITH base AS (
    SELECT *,
        CASE
            WHEN collateral_type = 'cash' THEN
                CASE
                    WHEN POSITION(',' IN ClearingService) > 0 THEN 'LDR'
                    WHEN TransactionType = 'TRIPARTY' THEN 'NA'
                    WHEN ClearingService IN ('SwapClear', 'ForexClear') AND CollateralAccountClassification = 'Client' THEN 
                        CASE
                            WHEN Currency IN ('EUR', 'USD', 'GBP') THEN 'CDR'
                            ELSE 'LDR'
                        END
                    WHEN ClearingService = 'SwapClear' AND SegregationType = 'FCM' THEN
                        CASE
                            WHEN Currency IN ('EUR', 'USD', 'GBP') THEN 'FCM'
                            ELSE 'LDR'
                        END
                    WHEN ClearingService = 'RepoClear' THEN
                        CASE
                            WHEN Currency IN ('EUR', 'USD', 'GBP') THEN 'RDR'
                            ELSE 'LDR'
                        END
                    ELSE 'LDR'
                END
            WHEN collateral_type = 'non_cash' THEN
                CASE
                    WHEN ClearingService IN ('SwapClear', 'ForexClear') AND CollateralAccountClassification = 'Client' THEN 'SWP_FXC_client'
                    WHEN TransactionType = 'TRIPARTY' THEN 'Triparty'
                    ELSE 'Bilateral'
                END
            ELSE InterestType
        END AS InterestType
    FROM {{ ref('base_table') }} -- Replace base_table with your actual table
)

SELECT * FROM base
