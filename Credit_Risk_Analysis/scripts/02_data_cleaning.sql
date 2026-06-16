USE CreditRisk_Portfolio
GO

--PHASE 2: DATA CLEANING (Làm sạch và chuẩn hóa)

-- Xóa View cũ nếu đã tồn tại để tránh lỗi khi chạy lại
IF OBJECT_ID('vw_CleanedLoanData', 'V') IS NOT NULL
    DROP VIEW vw_CleanedLoanData;
GO

-- Bắt đầu tạo phễu lọc dữ liệu (View)
CREATE VIEW vw_CleanedLoanData AS
SELECT 
    loan_amnt,
    
    -- 1. Xử lý cột 'term': Cắt bỏ chữ ' months' và ép về số nguyên (INT)
    CAST(REPLACE(term, ' months', '') AS INT) AS term_months,
    
    int_rate,
    installment,
    grade,
    sub_grade,
    
    -- 2. Xử lý cột 'emp_length': Chuyển chữ thành số và xử lý NULL
    CASE 
        WHEN emp_length IS NULL THEN -1  -- Đánh dấu -1 cho nhóm không khai báo
        WHEN LTRIM(RTRIM(emp_length)) = '< 1 year' THEN 0
        WHEN LTRIM(RTRIM(emp_length)) = '10+ years' THEN 10
        ELSE CAST(REPLACE(REPLACE(emp_length, ' years', ''), ' year', '') AS INT)
    END AS emp_length_years,
    
    home_ownership,
    annual_inc,
    verification_status,
    issue_d,
    loan_status,
    purpose,
    dti,
    
    -- 3. Xử lý cột 'revol_util': Nếu rỗng thì mặc định là 0%
    COALESCE(revol_util, 0) AS revol_util_percent, 
    
    delinq_2yrs,
    inq_last_6mths,
    open_acc,
    pub_rec,
    revol_bal,
    total_acc
FROM LoanData;
GO

-- Kiểm tra lại thành quả sau khi qua phễu lọc
SELECT TOP 20 
    term_months, 
    emp_length_years, 
    revol_util_percent
FROM vw_CleanedLoanData;
