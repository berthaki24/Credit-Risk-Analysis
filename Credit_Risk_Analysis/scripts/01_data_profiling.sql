USE CreditRisk_Portfolio

--PHASE 1: DATA PROFILING (Khám phá dữ liệu)

--1. Kiểm tra 10 dòng đầu của dataset
SELECT TOP 10 *
FROM LoanData

--2. Tổng quan: Đếm tổng số lượng khoản vay và tổng số tiền đã giải ngân
SELECT 
    COUNT(loan_amnt) AS Total_Loans,
    SUM(loan_amnt) AS Total_Funded_Amount,
    AVG(int_rate) AS Average_Interest_Rate
FROM LoanData;

-- 3. Phân tích biến mục tiêu (Target Variable): Tỷ lệ nợ xấu là bao nhiêu?
SELECT 
    loan_status,
    COUNT(*) AS Number_Of_Loans,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM LoanData) AS DECIMAL(5,2)) AS Percentage_Percent
FROM LoanData
GROUP BY loan_status
ORDER BY Number_Of_Loans DESC;