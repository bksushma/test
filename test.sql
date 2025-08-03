%sql ---Pmt_Approval#, Pmt_Approval$
with For_Dun_Commercial As(SELECT
    COUNT(CASE WHEN IsAuthApproval = TRUE THEN 1 END) AS Pmt_Approval_TransactionId,
    SUM(CASE WHEN IsAuthApproval = TRUE THEN AmountUSD END) AS Pmt_Approval_TransactionAmount,
    COUNT(CASE WHEN IsAuthTerminalState = TRUE THEN 1 END) AS Pmt_Terminal_TransactionId,
    SUM(CASE WHEN IsAuthTerminalState = TRUE THEN AmountUSD END) AS Pmt_Terminal_TransactionAmount
  FROM gold.transactions
  WHERE ProviderName <> 'Stored Value'
    and IsTransactionAbandoned = FALSE
    AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
    AND ConsumerOrCommercial = 'Commercial'
    AND IsLatestDunAttemptByCycle = TRUE
    AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
    AND COALESCE(TO_DATE(DunningFirstAttemptDateByCycle), Date) = "2025-07-01"
),
For_Dun_Consumer As(SELECT
    COUNT(CASE WHEN IsAuthApproval = TRUE THEN 1 END) AS Pmt_Approval_TransactionId,
    SUM(CASE WHEN IsAuthApproval = TRUE THEN AmountUSD END) AS Pmt_Approval_TransactionAmount,
    COUNT(CASE WHEN IsAuthTerminalState = TRUE THEN 1 END) AS Pmt_Terminal_TransactionId,
    SUM(CASE WHEN IsAuthTerminalState = TRUE THEN AmountUSD END) AS Pmt_Terminal_TransactionAmount
FROM gold.transactions
WHERE 
    ProviderName <> 'Stored Value'
    AND IsTransactionAbandoned = FALSE
    AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
    AND ConsumerOrCommercial = 'Consumer'
    AND IsLatestDunAttemptByCycle = TRUE
    AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
    AND COALESCE(TO_DATE(DunningFirstAttemptDateByCycle), Date) = "2025-07-01"
),

For_Pmt_Approval_CI_NoPayNow as (SELECT
  COUNT(CASE WHEN IsPayNow = FALSE and IsAuthApproval = TRUE THEN TransactionId END) AS Pmt_Approval_TransactionId,
  SUM(CASE WHEN IsAuthApproval = TRUE and IsPayNow = FALSE THEN AmountUSD END) AS Pmt_Approval_TransactionAmount,
  COUNT(CASE WHEN IsPayNow = FALSE and  IsAuthTerminalState = TRUE THEN 1 END) AS Pmt_Terminal_TransactionId,
  SUM(CASE WHEN IsAuthTerminalState = TRUE and IsPayNow = FALSE THEN AmountUSD END) AS Pmt_Terminal_TransactionAmount
FROM gold.transactions
where ProviderName <> 'Stored Value'
AND IsTransactionAbandoned = FALSE
AND CustomerOrMerchantInitiated = 'CustomerInitiated'
AND IsLastCustomerRetry = TRUE
AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
AND COALESCE(TO_DATE(DunningFirstAttemptDateByCycle), Date) = "2025-07-01"
),
For_Pmt_Approval_MI_NoDun as (SELECT
  COUNT(CASE WHEN IsAuthApproval = TRUE and IsDunningCycle = FALSE THEN 1 END) AS Pmt_Approval_TransactionId,
  SUM(CASE WHEN IsAuthApproval = TRUE and IsDunningCycle = FALSE THEN AmountUSD END) AS Pmt_Approval_TransactionAmount,
  COUNT(CASE WHEN IsAuthTerminalState = TRUE and IsDunningCycle = FALSE THEN 1 END) AS Pmt_Terminal_TransactionId,
  SUM(CASE WHEN IsAuthTerminalState = TRUE and  IsDunningCycle = FALSE THEN AmountUSD END) AS Pmt_Terminal_TransactionAmount
FROM gold.transactions
WHERE ProviderName <> 'Stored Value'
AND IsTransactionAbandoned = FALSE
AND CustomerOrMerchantInitiated = 'MerchantInitiated'
AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
AND (IsLastMerchantRetry = true OR DunAttemptByCycle IS NULL)
AND COALESCE(TO_DATE(DunningFirstAttemptDateByCycle), Date) = "2025-07-01"
)

select (select Pmt_Approval_TransactionId from For_Dun_Commercial)+(select Pmt_Approval_TransactionId from For_Dun_Consumer)+(select Pmt_Approval_TransactionId from For_Pmt_Approval_CI_NoPayNow)+(select Pmt_Approval_TransactionId from For_Pmt_Approval_MI_NoDun) as Pmt_Approvalcount,

(select Pmt_Approval_TransactionAmount from For_Dun_Commercial)+(select Pmt_Approval_TransactionAmount from For_Dun_Consumer)+(select Pmt_Approval_TransactionAmount from For_Pmt_Approval_CI_NoPayNow)+(select Pmt_Approval_TransactionAmount from For_Pmt_Approval_MI_NoDun) as Pmt_ApprovallDoller
