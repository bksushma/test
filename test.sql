SELECT
    -- Approval Percentage by Count
    (
        (SELECT Pmt_Approval_TransactionId FROM For_Dun_Commercial_FA) +
        (SELECT Pmt_Approval_TransactionId FROM For_Dun_Consumer_FA) +
        (SELECT Pmt_Approval_TransactionId FROM For_Pmt_Approval_CI_FA_NoPayNow) +
        (SELECT Pmt_Approval_TransactionId FROM For_Pmt_Approval_MI_FA_NoDun)
    ) * 100.0 /
    NULLIF(
        (SELECT Pmt_Terminal_TransactionId FROM For_Dun_Commercial_FA) +
        (SELECT Pmt_Terminal_TransactionId FROM For_Dun_Consumer_FA) +
        (SELECT Pmt_Terminal_TransactionId FROM For_Pmt_Approval_CI_FA_NoPayNow) +
        (SELECT Pmt_Terminal_TransactionId FROM For_Pmt_Approval_MI_FA_NoDun),
        0
    ) AS Approval_Percentage_FA,

    -- Approval Percentage by Amount (Dollar)
    (
        (SELECT Pmt_Approval_TransactionAmount FROM For_Dun_Commercial_FA) +
        (SELECT Pmt_Approval_TransactionAmount FROM For_Dun_Consumer_FA) +
        (SELECT Pmt_Approval_TransactionAmount FROM For_Pmt_Approval_CI_FA_NoPayNow) +
        (SELECT Pmt_Approval_TransactionAmount FROM For_Pmt_Approval_MI_FA_NoDun)
    ) * 100.0 /
    NULLIF(
        (SELECT Pmt_Terminal_TransactionAmount FROM For_Dun_Commercial_FA) +
        (SELECT Pmt_Terminal_TransactionAmount FROM For_Dun_Consumer_FA) +
        (SELECT Pmt_Terminal_TransactionAmount FROM For_Pmt_Approval_CI_FA_NoPayNow) +
        (SELECT Pmt_Terminal_TransactionAmount FROM For_Pmt_Approval_MI_FA_NoDun),
        0
    ) AS Approval_PercentageDoller_FA
