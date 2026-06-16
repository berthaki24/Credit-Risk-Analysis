USE CreditRisk_Portfolio
GO

--1. Phân tích Mối quan hệ giữa Hạng Tín Dụng (Grade) và Lãi Suất + Tỷ Lệ Nợ Xấu
SELECT 
    grade,
    COUNT(*) AS Total_Loans,
    -- Tính tổng số ca nợ xấu (Charged Off và Default)
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) AS Bad_Loans,
    -- Tính tỷ lệ nợ xấu (%)
    CAST(SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate_Percent,
    -- Tính lãi suất trung bình của từng nhóm
    CAST(AVG(int_rate) AS DECIMAL(5,2)) AS Avg_Interest_Rate_Percent
FROM vw_CleanedLoanData
GROUP BY grade
ORDER BY grade;

--RESULTS: Credit Grading System Assessment (Đánh giá Hiệu quả Hệ thống Xếp hạng Tín dụng)

--Strong Positive Correlation in Risk Assessment: The credit grading system demonstrates high accuracy in risk stratification. 
--As the credit grade downgrades (from A to G), the default rate sharply increases, escalating from a safe 6.52% (Grade A) 
--to an alarming 51.27% (Grade G). (Mối tương quan tỷ lệ thuận rõ rệt: Có sự phân hóa rủi ro cực kỳ chuẩn xác giữa các 
--nhóm khách hàng. Hạng tín dụng càng giảm (từ A xuống G), tỷ lệ nợ xấu (Default Rate) càng tăng phi mã, dao động từ mức 
--rất an toàn là 6.52% (Hạng A) lên tới mức báo động đỏ 51.27% (Hạng G). Nghĩa là ở nhóm G, cứ 2 người vay thì có hơn 1 người 
--bùng nợ.)

--Effective Risk-Based Pricing Mechanism: The Fintech platform successfully implements risk-based pricing to hedge against 
--potential losses. The average interest rate is proportionally adjusted upwards alongside the default risk, rising from 7.14% 
--for prime borrowers (Grade A) to a punitive 27.41% for subprime borrowers (Grade G). (Chiến lược Định giá theo Rủi ro 
--hiệu quả: Nền tảng Fintech đã thực hiện rất tốt việc dùng lãi suất để bù đắp rủi ro. Đi kèm với tỷ lệ nợ xấu tăng, 
--lãi suất trung bình cũng được ép tăng tuyến tính từ 7.14% (nhóm A) lên tới 27.41% (nhóm G).

--Portfolio Distribution & Risk Appetite: The loan volume distribution indicates that the platform's core target market is not 
--the safest tier, but rather the near-prime segment (Grades B and C), which accounts for the vast majority of issued loans. 
--This reflects a typical consumer finance strategy aimed at maximizing profit margins. (Khẩu vị rủi ro của nền tảng: Phân bổ 
--danh mục cho thấy nền tảng này không tập trung vào nhóm khách hàng an toàn nhất (A) mà đổ dồn khối lượng 
--giải ngân lớn nhất vào nhóm rủi ro trung bình (B và C với tổng cộng hơn 28,000 hồ sơ). Đây là chiến lược tối ưu hóa biên 
--lợi nhuận đặc trưng của các công ty tài chính tiêu dùng.


--2. Phân tích Nhóm khách hàng Giấu thông tin thâm niên (Mã hóa bằng -1 lúc nãy)
SELECT 
    CASE 
        WHEN emp_length_years = -1 THEN 'Unknown'
        WHEN emp_length_years = 0 THEN 'Less than 1 Year'
        WHEN emp_length_years BETWEEN 1 AND 3 THEN 'Short-Term (1-3 Years)'
        WHEN emp_length_years BETWEEN 4 AND 6 THEN 'Medium-Term (4-6 Years)'
        ELSE 'Stable (>6 Years)'
    END AS Employment_Group,
    COUNT(*) AS Total_Loans,
    CAST(
        SUM(
            CASE 
                WHEN loan_status IN ('Charged Off', 'Default') THEN 1 
                ELSE 0 
            END
        ) * 100.0 / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS Default_Rate_Percent
FROM vw_CleanedLoanData
GROUP BY 
    CASE 
        WHEN emp_length_years = -1 THEN 'Unknown'
        WHEN emp_length_years = 0 THEN 'Less than 1 Year'
        WHEN emp_length_years BETWEEN 1 AND 3 THEN 'Short-Term (1-3 Years)'
        WHEN emp_length_years BETWEEN 4 AND 6 THEN 'Medium-Term (4-6 Years)'
        ELSE 'Stable (>6 Years)'
    END
ORDER BY Default_Rate_Percent DESC;

--RESULTS: Employment Stability & Information Transparency Risk Analysis (Đánh giá Rủi ro theo Thâm niên công tác & Tính minh bạch thông tin)

--The "Missing Information" Risk Premium (Red Flag): The "Unknown" group (borrowers with undisclosed employment length) 
--exhibits a significantly elevated default rate of 27.43%, starkly outperforming all other cohorts (~20%). This validates 
--a fundamental credit underwriting principle: A lack of data transparency is a major behavioral indicator of high default risk. 
--The analytical decision to isolate and impute missing values rather than dropping them successfully uncovered this critical 
--insight. (Tính minh bạch tỷ lệ nghịch với rủi ro tín dụng: Nhóm khách hàng "Giấu thông tin" (Unknown) ghi nhận 
--tỷ lệ nợ xấu vọt lên mức cao nhất là 27.43%, cách biệt hoàn toàn so với mặt bằng chung (~20%). Điều này chứng minh một 
--quy luật cốt lõi trong thẩm định: Việc thiếu hụt hoặc cố tình không cung cấp dữ liệu thâm niên là một tín hiệu cảnh báo rủi ro 
--bùng nợ cực kỳ cao. Quyết định không xóa bỏ các giá trị rỗng (Missing Values) mà gán nhãn thành một nhóm độc lập đã phát huy 
--tác dụng, giúp khám phá ra insight hành vi đắt giá này.)

--Inverse Correlation Between Job Tenure and Credit Risk: Among borrowers with disclosed employment histories, the data reveals 
--a consistent downward trend in risk as job tenure increases. The default rate gradually declines from 20.37% (Less than 1 Year) 
--to the lowest point of 19.31% (Stable >6 Years). While the variance is relatively narrow, it confirms the premise that prolonged 
--employment stability correlates directly with better debt servicing capability and financial resilience. (Mối liên hệ giữa độ 
--ổn định công việc và khả năng trả nợ: Đối với nhóm có khai báo thông tin, dữ liệu cho thấy xu hướng rủi ro giảm dần một cách 
--đều đặn khi thâm niên làm việc tăng lên. Tỷ lệ nợ xấu giảm từ 20.37% (nhóm Dưới 1 năm) xuống mức an toàn nhất là 19.31% 
--(nhóm Ổn định >6 năm). Mặc dù mức chênh lệch không quá gắt, nó vẫn khẳng định rằng tính liên tục và ổn định của nguồn thu nhập 
--đóng vai trò quan trọng trong việc đảm bảo hành vi trả nợ đúng hạn.)


--3. Top 3 Mục đích vay (Purpose) có tỷ lệ nợ xấu cao nhất theo từng Phân khúc Thu nhập
WITH Income_and_Purpose_Metrics AS (
    SELECT 
        purpose,
        CASE 
            WHEN annual_inc < 45000 THEN 'Low Income (<45k)'
            WHEN annual_inc BETWEEN 45000 AND 85000 THEN 'Middle Income (45k-85k)'
            ELSE 'High Income (>85k)'
        END AS Income_Segment,
        CASE 
            WHEN loan_status IN ('Charged Off', 'Default') THEN 1 
            ELSE 0 
        END AS Is_Bad_Loan
    FROM vw_CleanedLoanData
),
Calculated_Risk AS (
    SELECT 
        Income_Segment,
        purpose,
        COUNT(*) AS Total_Loans,
        CAST(
            SUM(Is_Bad_Loan) * 100.0 / COUNT(*) 
            AS DECIMAL(5,2)
        ) AS Default_Rate,        
        -- Dùng Window Function để xếp hạng mức độ rủi ro trong từng phân khúc thu nhập
        ROW_NUMBER() OVER (
            PARTITION BY Income_Segment
            ORDER BY SUM(Is_Bad_Loan) * 100.0 / COUNT(*) DESC
        ) AS Risk_Rank        
    FROM Income_and_Purpose_Metrics
    GROUP BY Income_Segment, purpose
)
SELECT 
    Income_Segment,
    purpose,
    Total_Loans,
    Default_Rate
FROM Calculated_Risk
WHERE Risk_Rank <= 3
  AND Total_Loans > 50  -- Chỉ lấy top 3 rủi ro nhất và có quy mô mẫu > 50 hồ sơ
ORDER BY Income_Segment, Default_Rate DESC;

--RESULTS: Cross-Segment Risk Analysis by Loan Purpose (Phân tích Rủi ro chéo theo Mục đích vay)

--"Small Business" loans represent the most toxic asset class across all wealth segments, consistently exhibiting default rates 
--near 30% even among High-Income borrowers (29.88%).
--(Các khoản vay "Kinh doanh nhỏ" là danh mục tài sản độc hại nhất trên mọi phân khúc tài sản, liên tục ghi nhận tỷ lệ nợ xấu 
--sát mốc 30% ngay cả ở nhóm khách hàng Thu nhập cao - 29.88%.)

--For Low-Income earners, transitional life events such as "moving" (29.66%) and "house" (26.79%) trigger the highest default 
--probabilities, indicating a severe lack of financial buffers to sustain debt obligations during periods of personal instability.
--(Đối với nhóm Thu nhập thấp, các sự kiện chuyển giao cuộc sống như "chuyển nhà" (29.66%) và "nhà ở" (26.79%) kích hoạt xác suất 
--vỡ nợ cao nhất, cho thấy sự thiếu hụt trầm trọng các bộ đệm tài chính để duy trì nghĩa vụ trả nợ trong những giai đoạn bất ổn 
--cá nhân.)

--Strategic Recommendation: To mitigate future credit losses, the underwriting department must aggressively tighten approval 
--conditions, demand stronger proof of cash flow, or significantly reduce credit limits for "small_business" and "moving" purposes 
--across the entire portfolio.
--(Khuyến nghị Chiến lược: Để giảm thiểu tổn thất tín dụng trong tương lai, bộ phận thẩm định cần quyết liệt thắt chặt điều kiện 
--phê duyệt, yêu cầu bằng chứng dòng tiền mạnh mẽ hơn, hoặc giảm đáng kể hạn mức tín dụng đối với các mục đích vay "kinh doanh nhỏ" 
--và "chuyển nhà" trên toàn bộ danh mục.)