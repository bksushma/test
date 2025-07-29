  FROM gold.transactions
  WHERE
    IsAuthTerminalState = TRUE
    AND ProviderName <> 'Stored Value'
    AND IsTransactionAbandoned = FALSE
    AND (CustomerOrMerchantInitiated = 'MerchantInitiated' OR IsPayNow = TRUE)
    AND ConsumerOrCommercial = 'Consumer'
    AND IsLatestDunAttemptByCycle = TRUE
    AND (IsLastDynamicRetry = TRUE OR IsLastDynamicRetry IS NULL)
)
