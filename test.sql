%sql -- NO --doc WITHfilters--hard
WITH declined_transactions AS (
    SELECT 
        BillingRecordId,
        DATE_FORMAT(DATE_TRUNC('MONTH', DunningFirstAttemptDate),'yyyy-MM-dd') AS DeclineMonth,
        DunningFirstAttemptDate
    FROM 
        gold.transactions
    WHERE 
        cast(DunningFirstAttemptDate AS Date) >= '2025-01-01'
        AND IsAuthTerminalState = TRUE
        AND ProviderName <> 'Stored Value'
        AND NOT IsTransactionAbandoned
        AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
        AND ConsumerOrCommercial = 'Consumer'
        AND DunAttempt=1
        AND DynamicRetryAttempt =0
        AND TransactionType = "CHARGE"
        --AND IsLatestDunAttemptByCycle = TRUE
        --AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
        AND StatusDetailsCode IN ('CVVVALUEMISMATCH',
          'INCORRECTPINORPASSCODE',
          'INVALIDPAYMENTINSTRUMENT',
            'AMOUNTLIMITEXCEEDED',
            'AUTHENTICATIONREQUIRED',  
            'TRANSACTIONNOTALLOWED',
            'PROCESSORRISKCHECKDECLINED',
            'INVALIDMOBIINPUT',
            'INVALIDLINEITEMDETAIL')
),
approved_transactions AS (
    SELECT 
        BillingRecordId
    FROM 
        gold.transactions
    WHERE 
        TransactionStatus = 'APPROVED'
)
SELECT 
    d.DeclineMonth,
    COUNT(DISTINCT d.BillingRecordId) AS Total_Declined_Transactions,
    COUNT(DISTINCT a.BillingRecordId) AS Recovered_Transactions,
    ROUND((COUNT(DISTINCT a.BillingRecordId) * 100.0 / COUNT(DISTINCT d.BillingRecordId)), 2) AS Recovery_Rate_Percent
FROM 
    declined_transactions d
LEFT JOIN 
    approved_transactions a ON d.BillingRecordId = a.BillingRecordId
GROUP BY 
    d.DeclineMonth
ORDER BY 
    d.DeclineMonth DESC;

#soft
%sql -- yes---doc WITHfilters--soft
WITH declined_transactions AS (
    SELECT 
        BillingRecordId,
        DATE_FORMAT(DATE_TRUNC('MONTH', DunningFirstAttemptDate),'yyyy-MM-dd') AS DeclineMonth,
        DunningFirstAttemptDate
    FROM 
        gold.transactions
    WHERE 
        cast(DunningFirstAttemptDate AS Date) >= '2025-01-01'
        AND IsAuthTerminalState = TRUE
        AND ProviderName <> 'Stored Value'
        AND NOT IsTransactionAbandoned
        AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
        AND ConsumerOrCommercial = 'Consumer'
        AND DunAttempt=1
        AND DynamicRetryAttempt !=0
        AND TransactionType = "CHARGE"
        --AND DunAttemptByCycle = 1
        --AND IsLatestDunAttemptByCycle = TRUE
        --AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
        AND StatusDetailsCode IN (
          'PROCESSORDECLINED',
            'INSUFFICIENTFUND',
            'AUTHORIZATIONEXPIRED',
            'PAYMENTPROCESSORFAILURE',
            'MISSINGFUNDINGSOURCE',
            'EXPIREDPAYMENTINSTRUMENT')
),
approved_transactions AS (
    SELECT 
        BillingRecordId
    FROM 
        gold.transactions
    WHERE 
        TransactionStatus = 'APPROVED'
)
SELECT 
    d.DeclineMonth,
    COUNT(DISTINCT d.BillingRecordId) AS Total_Declined_Transactions,
    COUNT(DISTINCT a.BillingRecordId) AS Recovered_Transactions,
    ROUND((COUNT(DISTINCT a.BillingRecordId) * 100.0 / COUNT(DISTINCT d.BillingRecordId)), 2) AS Recovery_Rate_Percent
FROM 
    declined_transactions d
LEFT JOIN 
    approved_transactions a ON d.BillingRecordId = a.BillingRecordId
GROUP BY 
    d.DeclineMonth
ORDER BY 
    d.DeclineMonth DESC;


%sql
select TransactionId from gold.transactions where SubscriptionId is not null




