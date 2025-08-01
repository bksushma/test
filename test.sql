SELECT
    SUM(CASE WHEN IsAuthTerminalState = TRUE
           AND ProviderName <> 'Stored Value'
           AND IsTransactionAbandoned = FALSE
           AND CustomerOrMerchantInitiated = 'CustomerInitiated'
           AND IsLastCustomerRetry = TRUE
           AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
           AND IsPayNow = FALSE
         THEN TransactionCount END) AS Pmt_TotalNum_CI_NoPayNow,

    SUM(CASE WHEN IsAuthTerminalState = TRUE
           AND ProviderName <> 'Stored Value'
           AND IsTransactionAbandoned = FALSE
           AND CustomerOrMerchantInitiated = 'MerchantInitiated'
           AND (IsLastMerchantRetry = TRUE OR DunAttemptByCycle IS NULL)
           AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
           AND IsDunningCycle = FALSE
         THEN TransactionCount END) AS Pmt_TotalNum_MI_NoDun

FROM gold.transactions
