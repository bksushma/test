let For_Dun_Commercial = 
    gold_transactions
    | where ProviderName != "Stored Value"
        and IsTransactionAbandoned == false
        and (CustomerOrMerchantInitiated == "MerchantInitiated" or IsPayNow == true)
        and ConsumerOrCommercial == "Commercial"
        and IsLatestDunAttemptByCycle == true
        and (IsLastDynamicRetry == true or isnull(IsLastDynamicRetry))
        and coalesce(todatetime(DunningFirstAttemptDateByCycle), Date) == datetime(2025-07-01)
    | summarize 
        Pmt_Approval_TransactionId = countif(IsAuthApproval == true),
        Pmt_Approval_TransactionAmount = sumif(AmountUSD, IsAuthApproval == true);

let For_Dun_Consumer = 
    gold_transactions
    | where ProviderName != "Stored Value"
        and IsTransactionAbandoned == false
        and (CustomerOrMerchantInitiated == "MerchantInitiated" or IsPayNow == true)
        and ConsumerOrCommercial == "Consumer"
        and IsLatestDunAttemptByCycle == true
        and (IsLastDynamicRetry == true or isnull(IsLastDynamicRetry))
        and coalesce(todatetime(DunningFirstAttemptDateByCycle), Date) == datetime(2025-07-01)
    | summarize 
        Pmt_Approval_TransactionId = countif(IsAuthApproval == true),
        Pmt_Approval_TransactionAmount = sumif(AmountUSD, IsAuthApproval == true);

let For_Pmt_Approval_CI_NoPayNow =
    gold_transactions
    | where ProviderName != "Stored Value"
        and IsTransactionAbandoned == false
        and CustomerOrMerchantInitiated == "CustomerInitiated"
        and IsLastCustomerRetry == true
        and (IsLastDynamicRetry == true or isnull(IsLastDynamicRetry))
        and IsPayNow == false
        and coalesce(todatetime(DunningFirstAttemptDateByCycle), Date) == datetime(2025-07-01)
    | summarize 
        Pmt_Approval_TransactionId = countif(IsAuthApproval == true),
        Pmt_Approval_TransactionAmount = sumif(AmountUSD, IsAuthApproval == true);

let For_Pmt_Approval_MI_NoDun =
    gold_transactions
    | where ProviderName != "Stored Value"
        and IsTransactionAbandoned == false
        and CustomerOrMerchantInitiated == "MerchantInitiated"
        and (IsLastDynamicRetry == true or isnull(IsLastDynamicRetry))
        and (IsLastMerchantRetry == true or isnull(DunAttemptByCycle))
        and IsDunningCycle == false
        and coalesce(todatetime(DunningFirstAttemptDateByCycle), Date) == datetime(2025-07-01)
    | summarize 
        Pmt_Approval_TransactionId = countif(IsAuthApproval == true),
        Pmt_Approval_TransactionAmount = sumif(AmountUSD, IsAuthApproval == true);

datatable(dummy:int) [1]
| extend
    Pmt_Approvalcount = 
        toscalar(For_Dun_Commercial | project Pmt_Approval_TransactionId) +
        toscalar(For_Dun_Consumer | project Pmt_Approval_TransactionId) +
        toscalar(For_Pmt_Approval_CI_NoPayNow | project Pmt_Approval_TransactionId) +
        toscalar(For_Pmt_Approval_MI_NoDun | project Pmt_Approval_TransactionId),
    Pmt_ApprovalDoller =
        toscalar(For_Dun_Commercial | project Pmt_Approval_TransactionAmount) +
        toscalar(For_Dun_Consumer | project Pmt_Approval_TransactionAmount) +
        toscalar(For_Pmt_Approval_CI_NoPayNow | project Pmt_Approval_TransactionAmount) +
        toscalar(For_Pmt_Approval_MI_NoDun | project Pmt_Approval_TransactionAmount)
| project-away dummy
