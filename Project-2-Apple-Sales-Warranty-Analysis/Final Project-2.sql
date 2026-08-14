
-- استكشاف هيكل الجدول
EXEC sp_help'dbo.stores';

-- نظرة سريعة على بيانات الجدول
SELECT TOP 10*
FROM dbo.stores;


-- Find the number of stores in each country.
-- عدد المتاجر في كل دولة
SELECT 
	Country,
	COUNT(*) AS Num_Store
FROM dbo.stores
GROUP BY Country
ORDER BY Num_Store DESC;





-- Calculate the total number of units sold by each store.
--  العدد الإجمالي للوحدات المباعة من قبل كل متجر

SELECT 
	s.Store_Name,
	SUM(sa.quantity) AS Total_Units_Sold
FROM dbo.AppleSales sa
JOIN dbo.stores s
    ON sa.store_id = s.Store_ID
GROUP BY s.Store_Name
ORDER BY Total_Units_Sold DESC;






-- Identify how many sales occurred in December 2023.
-- تحديد عدد المبيعات التي حدثت في ديسمبر 2023.
SELECT 
	COUNT(*) AS Num_Sales
FROM dbo.AppleSales
WHERE sale_date Between '2023-12-1' and '2023-12-31'







-- Determine how many stores have never had a warranty claim filed.
-- تحديد عدد المتاجر التي لم يتم تقديم أي مطالبة ضمان لها.

SELECT 
    COUNT(DISTINCT s.Store_ID) AS stores_with_no_claims

FROM dbo.stores s

LEFT JOIN dbo.AppleSales sa
    ON s.Store_ID = sa.store_id

LEFT JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id

WHERE w.claim_id IS NULL;





-- Calculate the percentage of warranty claims marked as "Warranty Void".
--"Warranty Void" was not available in the dataset, so "Rejected" was used instead.
-- نسبة مطالبات الضمان التي مرفوضة

SELECT
	COUNT(CASE WHEN repair_status = 'Warranty Void' THEN 1 END) *100.0 / COUNT(*) AS Percentage
FROM dbo.warranty;

SELECT
	COUNT(CASE WHEN repair_status = 'Rejected' THEN 1 END) *100.0 / COUNT(*) AS Percentage
FROM dbo.warranty;




-- Identify which store had the highest total units sold in the last year.
-- المتجر الذي كان لديه اعلى إجمالي للوحدات المباعة في العام الماضي
SELECT TOP 1
	s.Store_Name,
	SUM(sa.quantity) AS Total_Units_Sold
FROM dbo.AppleSales sa
JOIN dbo.stores s
ON sa.store_id = s.Store_ID
WHERE sa.sale_date >= DATEADD(YEAR, -1, GETDATE())
GROUP BY s.Store_Name
ORDER BY Total_Units_Sold DESC;






SELECT TOP 1
	s.Store_Name,
	SUM(sa.quantity) AS Total_Units_Sold
FROM dbo.AppleSales sa
JOIN dbo.stores s
ON sa.store_id = s.Store_ID
WHERE sa.sale_date >= DATEADD(YEAR, -1, (SELECT MAX(sa.sale_date) FROM dbo.AppleSales sa))
GROUP BY s.Store_Name
ORDER BY Total_Units_Sold DESC;




-- Count the number of unique products sold in the last year.
-- عدد المنتجات المختلفة او المميزة التي تم بيعها اخر سنه
SELECT 
    COUNT(DISTINCT p.Product_ID) AS Unique_Products_Sold
FROM dbo.products p
JOIN dbo.AppleSales sa
    ON p.Product_ID = sa.product_id
WHERE sa.sale_date >= DATEADD(YEAR, -1, (SELECT MAX(sale_date) FROM dbo.AppleSales));








SELECT 
    COUNT(DISTINCT p.Product_ID) AS Unique_Products_Sold
FROM dbo.products p
JOIN dbo.AppleSales sa
    ON p.Product_ID = sa.product_id
WHERE sa.sale_date >= DATEADD(YEAR, -1,GETDATE());





-- Find the average price of products in each category.
-- متوسط سعر كل فئة
SELECT
	c.category_name,
	AVG(p.Price) AS Avg_Price
FROM dbo.products p
JOIN dbo.category c
ON p.Category_ID = c.category_id
GROUP BY c.category_name 
ORDER BY AVG_Price DESC;




-- How many warranty claims were filed in 2020?
-- عدد مطالبات التأمين في سنة ٢٠٢٠

SELECT
	COUNT(*) AS Total_Claims_2020
FROM dbo.warranty
WHERE YEAR(claim_date) = 2020;








SELECT
	COUNT(*) AS Total_Claims_2020
FROM dbo.warranty
WHERE claim_date >= '2020-01-01' 
AND claim_date < '2021-01-01'

SELECT
	COUNT(*) AS Total_Claims_2024
FROM dbo.warranty
WHERE YEAR(claim_date) = 2024;


-- For each store, identify the best-selling day based on highest quantity sold. 
-- تحديد يوم البيع الأفضل لكل متجر بناءً على أكبر كمية مباعة
WITH Daily_Sales AS (
    SELECT
        sa.store_id,
        s.store_name,
        sa.sale_date,
        SUM(sa.quantity) AS Total_Quantity,
        ROW_NUMBER() OVER (PARTITION BY sa.store_id ORDER BY SUM(sa.quantity) DESC
        ) AS rn
    FROM dbo.AppleSales sa
    JOIN dbo.stores s
        ON sa.store_id = s.store_id
    GROUP BY
        sa.store_id,
        s.store_name,
        sa.sale_date
)

SELECT
    store_id,
    store_name,
    sale_date,
    Total_Quantity
FROM Daily_Sales
WHERE rn = 1
ORDER BY Total_Quantity DESC;



-- Identify the least selling product in each country for each year based on total units sold.
-- اقل المنتجات مبيعاً لكل سنه وقارة
WITH ranked AS (
    SELECT
        s.country,
        p.product_name,
        YEAR(sa.sale_date) AS sale_year,
        SUM(sa.quantity) AS total_units_sold,
        RANK() OVER (
            PARTITION BY s.country, YEAR(sa.sale_date)
            ORDER BY SUM(sa.quantity) ASC
        ) AS rn
    FROM dbo.AppleSales sa
    JOIN dbo.stores s
        ON sa.store_id = s.store_id
    JOIN dbo.products p
        ON sa.product_id = p.Product_ID
    GROUP BY
        s.country,
        p.product_name,
        YEAR(sa.sale_date)
)

SELECT
    country,
    product_name,
    sale_year,
    total_units_sold
FROM ranked
WHERE rn = 1;




-- Calculate how many warranty claims were filed within 180 days of a product sale.
-- عدد المطالبات للتامين خلال ١٨٠ يوم من تاريخ بيع المنتج

SELECT    
    COUNT(w.claim_id) AS Total_Claims
FROM dbo.AppleSales sa
JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id
WHERE DATEDIFF(day,sa.sale_date,w.claim_date) <= 180;








-- Determine how many warranty claims were filed for products launched in the last two years.
-- عدد طلبات الضمان التي تم تقديمها للمنتجات التي تم اطلاقها خلال السنتين السابقه
SELECT 
    COUNT(w.claim_id) AS Num_Claim
FROM dbo.AppleSales sa
JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id
JOIN dbo.products p
    ON sa.product_id = p.Product_ID
WHERE p.Launch_Date >= DATEADD(YEAR,-2, GETDATE());






--List the months in the last three years where sales exceeded 5,000 units in the USA. 
-- سرد الاشهر للسنوات الثلاث الماضيه حيث تجاوزت المبيعات ٥٠٠٠ وحدة في الولايات المتحدة
SELECT 
    YEAR(sa.sale_date) AS sale_year,
    MONTH(sa.sale_date) AS sale_month,
    SUM(sa.quantity) AS total_units
FROM dbo.AppleSales sa
JOIN dbo.stores s
    ON sa.store_id = s.Store_ID
WHERE s.Country = 'United States'
AND sa.sale_date >= DATEADD(YEAR, -3,(SELECT MAX(sale_date) FROM dbo.AppleSales))
GROUP BY 
    YEAR(sa.sale_date),
    MONTH(sa.sale_date)
HAVING SUM(sa.quantity) > 5000
ORDER BY sale_year, sale_month;


SELECT 
    YEAR(sa.sale_date) AS sale_year,
    MONTH(sa.sale_date) AS sale_month,
    SUM(sa.quantity) AS total_units
FROM dbo.AppleSales sa
JOIN dbo.stores s
    ON sa.store_id = s.Store_ID
WHERE s.Country = 'United States'
AND sa.sale_date >= DATEADD(YEAR, -3,(SELECT MAX(sale_date) FROM dbo.AppleSales))
GROUP BY 
    YEAR(sa.sale_date),
    MONTH(sa.sale_date)
HAVING SUM(sa.quantity) > 400
ORDER BY sale_year, sale_month;




--Identify the product category with the most warranty claims filed in the last two years.
-- تصنيف المنتجات الاكثر تلقي لطلبات التامين خلال السنتين الماضيه 
SELECT TOP 1
    COUNT(w.claim_id) AS num_claim,
    c.category_name
FROM dbo.AppleSales sa
JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id
JOIN dbo.products p
    ON sa.product_id = p.Product_ID
JOIN dbo.category c
    ON p.Category_ID = c.category_id
WHERE w.claim_date >= DATEADD(YEAR,-2,GETDATE())
GROUP BY c.category_name 
ORDER BY num_claim DESC;



-- Determine the percentage chance of receiving a warranty claim after each purchase, for each country.
-- تحديد نسبة احتمال تلقي مطالبة بالضمان بعد كل عملية شراء، لكل دولة.
SELECT
    s.Country,
    COUNT(w.claim_id) AS num_claims,
    COUNT(sa.sale_id) AS total_sales,
    
    (COUNT(w.claim_id) * 100.0)
    / COUNT(sa.sale_id) AS claim_percentage

FROM dbo.AppleSales sa

JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id

JOIN dbo.stores s
    ON sa.store_id = s.Store_ID


GROUP BY s.Country;




-- Analyze the year-by-year growth ratio for each store. 
-- تحليل نسبة النمو على مدار السنوات لكل متجر 
WITH yearly_sales AS(

SELECT
    store_id,
    YEAR(sale_date) AS sale_year,
    SUM(quantity) AS total_sales

FROM dbo.AppleSales

GROUP BY 
    store_id,
    YEAR(sale_date)
),

growth_clac AS(
SELECT 
    store_id,
    sale_year,
    total_sales,

LAG(total_sales) OVER(
PARTITION BY store_id
ORDER BY sale_year) AS  previous_year_sales

FROM yearly_sales
)

SELECT 
    store_id,
    sale_year,
    total_sales,
    previous_year_sales,

    ((total_sales -  previous_year_sales) * 100.0)
    / previous_year_sales AS growth_ratio

FROM growth_clac
ORDER BY store_id,sale_year;


--Calculate the correlation between product price and warranty claims for products sold in the last five years,segmented by price range.
--حساب الارتباط بين سعر المنتج ومطالبات الضمان للمنتجات المباعة في السنوات الخمس الماضية، مقسمة حسب نطاق السعر.
SELECT
   
   CASE
        WHEN  p.price < 500 THEN 'Cheap' 
        WHEN  p.price BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Expensive'
    END,
    
    COUNT(w.claim_id)

FROM dbo.AppleSales sa

JOIN dbo.products p
    ON sa.product_id = p.Product_ID

JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id

WHERE sa.sale_date >= DATEADD(YEAR,-5,GETDATE())

GROUP BY
    CASE
        WHEN  p.price < 500 THEN 'Cheap' 
        WHEN  p.price BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Expensive'
    END;



-- Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.
-- "Paid Repaired" status was not available in the dataset, therefore "Completed" was used as the closest equivalent.
-- حدد المتجر الذي لديه أعلى نسبة من المطالبات "تم إكتمالها" مقارنةً بإجمالي المطالبات المقدمة.
WITH num_claims AS (

SELECT
    sa.store_id,
    
    COUNT(claim_id) AS total_claims,
    
    COUNT(
        CASE
            WHEN repair_status= 'Completed'
            THEN 1
        END
        ) AS Completed_claims

FROM dbo.AppleSales sa

JOIN dbo.warranty w
    ON sa.sale_id = w.sale_id

GROUP BY
    sa.store_id
)

SELECT TOP 1
    store_id,
    total_claims,
    Completed_claims,
    
    (Completed_claims * 100.0)
    / total_claims AS claim_percentage

FROM num_claims

ORDER BY claim_percentage DESC;



-- Calculate the monthly running total of sales for each store over the past four years.
-- احسب المجموع التراكمي الشهري للمبيعات لكل متجر خلال السنوات الأربع الماضية 
WITH monthly_sales AS (

SELECT 
    store_id,
    YEAR(sale_date) AS year_sales,
    MONTH(sale_date) AS month_sales,
    SUM(quantity) AS monthly_total

FROM dbo.AppleSales

WHERE sale_date >= DATEADD(YEAR,-4,GETDATE())
GROUP BY

    store_id,
    YEAR(sale_date),
    MONTH(sale_date)
 )
 
SELECT
    store_id,
    year_sales,
    month_sales,
    monthly_total,

    SUM(monthly_total) OVER(
    PARTITION BY store_id ORDER BY
    year_sales, month_sales
    ROWS UNBOUNDED PRECEDING) AS running_total

FROM monthly_sales;



--Analyze product sales trends over time, segmented into 4 lifecycle periods.
--تحليل اتجاهات مبيعات المنتج بمرور الوقت، مقسمة إلى 4 فترات من دورة الحياة.
SELECT
    p.Product_Name,
    
    CASE 

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 0 AND 6
        THEN 'Launch phase'

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 6 AND 12 
        THEN 'Early maturity'

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 12 AND 18
        THEN 'Peak / Plateau'

    ELSE
        'Long tail'
    END AS lifecycle_stage,

    SUM(sa.quantity) AS total_sales

FROM dbo.AppleSales sa

JOIN dbo.products p
    ON sa.product_id = p.Product_ID

GROUP BY
    
    p.Product_Name,
    
    CASE 

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 0 AND 6
        THEN 'Launch phase'

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 6 AND 12 
        THEN 'Early maturity'

        WHEN DATEDIFF(MONTH,p.Launch_Date,sa.sale_date)
        BETWEEN 12 AND 18
        THEN 'Peak / Plateau'

    ELSE
        'Long tail'
    END;
