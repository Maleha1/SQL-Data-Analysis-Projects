
-- استكشاف هيكل الجدول
EXEC sp_help'dbo.menu_items';

-- عرض البيانات لفهم المحتوى 
SELECT TOP 10*
FROM dbo.menu_items;

-- عرض أسماء الأعمدة وأنواعها
SELECT 
	COLUMN_NAME,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'menu_items';

-- إجمالي عدد عناصر القائمة
SELECT 
    COUNT(*) AS Total_Item
FROM dbo.menu_items;

--Identify the least and most expensive items on the menu.
-- أرخص عنصر في القائمة
SELECT TOP 1 
    item_name, 
    price
FROM dbo.menu_items
ORDER BY price ASC;

-- أغلى عنصر في القائمة
SELECT TOP 1 
    item_name, 
    price
FROM dbo.menu_items
ORDER BY price DESC;

-- أغلى وأرخص عنصر في القائمة
SELECT 
    item_name, price, 'Cheapest' AS Type
FROM (
    SELECT TOP 1 item_name, price
    FROM dbo.menu_items
    ORDER BY price ASC
) AS Cheap

UNION ALL

SELECT 
    item_name, price, 'Most Expensive' AS Type
FROM (
    SELECT TOP 1 item_name, price
    FROM dbo.menu_items
    ORDER BY price DESC
) AS Expensive;


-- تحليل احصائي
SELECT 
    COUNT(*) AS Num_Item,
    MIN(price) AS Min_Price,
    MAX(price) AS Max_Price,
    AVG(price) AS Avg_Price
FROM dbo.menu_items
WHERE category = 'Italian';


-- عرض تنصيف الاطباق مع متوسط السعر من الأعلى للأقل
SELECT 
    category,
    COUNT(*) AS Num_Dish,
    ROUND(AVG(price),2) AS Avg_Price
FROM dbo.menu_items
GROUP BY category
ORDER BY Avg_Price DESC;


-- عرض تاريخ الطلب الأول والأخير
SELECT 
    MIN(order_date) as First_Order_Date,
    MAX(order_date) as Last_Order_Date  
FROM dbo.orders;


-- عرض عدد الطلبات الكلية مع عدد الأصناف المباعه
SELECT 
    COUNT(DISTINCT order_id) as Total_Order,
    COUNT(*) AS Total_Item_Sold
FROM dbo.orders;



--ترتيب الطلبات التي تحتوي على اكبر عدد عناصر 

SELECT 
    order_id,
    COUNT(*) AS Num_Items,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS Rank_Order
FROM dbo.orders
GROUP BY order_id
ORDER BY Num_Items DESC;


-- عدد الطلبات التي تحتوي على اكثر من 12 عنصر

WITH Order_Count AS (
SELECT
    order_id,
    COUNT(*) AS Num_Item
FROM dbo.orders
GROUP BY order_id 
)
SELECT 
    COUNT(*) AS Order_Over_12
FROM Order_Count
WHERE Num_Item > 12;


-- دمج جدول الطلبات مع جدول القائمة لإنتاج جدول شامل وموسع   

CREATE OR ALTER VIEW dbo.vw_OrderDetails AS
SELECT
    o.order_id,
    o.order_date,
    o.order_time,
    m.item_name,
    m.category,
    m.price
FROM dbo.orders AS o
LEFT JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id;
 
SELECT * 
FROM dbo.vw_OrderDetails;


-- العناصر الأكثر طلب من ناحية الحجم والايرادات
SELECT 
    m.item_name,
    m.category,
    COUNT(*) AS Times_Orders,
    ROUND(SUM(m.Price),2) AS Total_Revenues
FROM dbo.orders As o
JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id
GROUP BY m.item_name, m.category
ORDER BY Times_Orders DESC;

-- العناصر الاقل طلب من ناحية الحجم والايرادات
SELECT 
    m.item_name,
    m.category,
    COUNT(*) AS Times_Orders,
    ROUND(SUM(m.Price),2) AS Total_Revenues
FROM dbo.orders As o
JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id
GROUP BY m.item_name, m.category
ORDER BY Times_Orders ASC;


-- تحديد أعلى 5 طلبات من حيث الإنفاق  
SELECT TOP 5
    o.order_id,
    ROUND(SUM(m.price),2) AS Total_Price
FROM dbo.orders AS o
JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id
GROUP BY  o.order_id
ORDER BY Total_Price DESC;

-- فحص الطلب ذو الإنفاق الأعلى الوحيد: ما هي العناصر والفئات التي احتوى عليها
WITH TopOdrer  AS (
SELECT TOP 1
    o.order_id,
    ROUND(SUM(m.price),2) AS Total_Price
FROM dbo.orders AS o
JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id
GROUP BY  o.order_id
ORDER BY Total_Price DESC
)
SELECT 
    o.order_id,
    m.item_name,
    m.category
FROM TopOdrer as t
JOIN dbo.orders AS o 
    ON t.order_id = o.order_id
JOIN dbo.menu_items AS m 
    ON o.item_id = m.menu_item_id


-- قيمة أغلى طلب في المجموعة الكاملة من البيانات
SELECT 
    MAX(Total_Price) AS Highest_Order_Value
FROM (
SELECT 
    o.order_id,
    ROUND(SUM(m.price),2) AS Total_Price
FROM dbo.orders AS o
JOIN dbo.menu_items AS m
    ON o.item_id = m.menu_item_id
GROUP BY o.order_id
) t
