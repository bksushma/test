SELECT
    COUNT(CASE WHEN IsAuthApproval = TRUE THEN 1 END) AS Pmt_Approval_TransactionId,
    SUM(CASE WHEN IsAuthApproval = TRUE THEN AmountUSD END) AS Pmt_Approval_TransactionAmount,
    COUNT(CASE WHEN IsAuthTerminalState = TRUE THEN 1 END) AS Pmt_Terminal_TransactionId,
    SUM(CASE WHEN IsAuthTerminalState = TRUE THEN AmountUSD END) AS Pmt_Terminal_TransactionAmount
FROM gold.transactions
WHERE 
    ProviderName <> 'Stored Value'
    AND IsTransactionAbandoned = FALSE
    AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
    AND ConsumerOrCommercial = 'Commercial'
    AND IsLatestDunAttemptByCycle = TRUE
    AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
    AND DATE = '2025-07-01'
