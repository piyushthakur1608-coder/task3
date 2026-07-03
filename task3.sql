-- =====================================================
-- TASK 3: ADVANCED SQL ANALYSIS
-- =====================================================


-- =====================================================
-- 1. MONTHLY PERFORMANCE ANALYSIS
-- =====================================================

SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Sales) AS Monthly_Sales,
    SUM(Profit) AS Monthly_Profit
FROM Orders
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Year,
    Month;


-- =====================================================
-- 2. MONTH-OVER-MONTH SALES GROWTH
-- Better version using LAG()
-- =====================================================

WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Year,
        MONTH(Order_Date) AS Month,
        SUM(Sales) AS Monthly_Sales
    FROM Orders
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

SalesWithPreviousMonth AS
(
    SELECT
        Year,
        Month,
        Monthly_Sales,

        LAG(Monthly_Sales) OVER
        (
            ORDER BY Year, Month
        ) AS Previous_Month_Sales

    FROM MonthlySales
)

SELECT
    Year,
    Month,
    Monthly_Sales,
    Previous_Month_Sales,

    Monthly_Sales - Previous_Month_Sales
        AS Sales_Variance,

    ROUND(
        (
            (Monthly_Sales - Previous_Month_Sales)
            / NULLIF(Previous_Month_Sales, 0)
        ) * 100,
        2
    ) AS Growth_Percentage

FROM SalesWithPreviousMonth
ORDER BY Year, Month;


-- =====================================================
-- 3. ORDER VALUE CLASSIFICATION USING CASE
-- =====================================================

SELECT
    Order_ID,
    Order_Date,
    Customer_ID,
    Category,
    Sales,

    CASE
        WHEN Sales > 1000 THEN 'High Value'
        WHEN Sales BETWEEN 500 AND 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Order_Type

FROM Orders;


-- =====================================================
-- 4. COUNT ORDERS BY ORDER VALUE CLASSIFICATION
-- =====================================================

SELECT
    CASE
        WHEN Sales > 1000 THEN 'High Value'
        WHEN Sales BETWEEN 500 AND 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Order_Type,

    COUNT(*) AS Total_Orders,

    SUM(Sales) AS Total_Sales,

    SUM(Profit) AS Total_Profit

FROM Orders

GROUP BY

    CASE
        WHEN Sales > 1000 THEN 'High Value'
        WHEN Sales BETWEEN 500 AND 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END;


-- =====================================================
-- 5. REGION PERFORMANCE ANALYSIS
-- =====================================================

SELECT
    c.Region,

    SUM(o.Sales) AS Total_Sales,

    SUM(o.Profit) AS Total_Profit,

    ROUND(
        SUM(o.Profit) * 100.0 /
        NULLIF(SUM(o.Sales), 0),
        2
    ) AS Profit_Margin_Percentage

FROM Orders o

INNER JOIN Customers c
    ON o.Customer_ID = c.Customer_ID

GROUP BY c.Region

ORDER BY Total_Profit DESC;


-- =====================================================
-- 6. IDENTIFY UNDERPERFORMING REGIONS
-- PDF threshold method
-- =====================================================

SELECT
    c.Region,
    SUM(o.Profit) AS Total_Profit

FROM Orders o

INNER JOIN Customers c
    ON o.Customer_ID = c.Customer_ID

GROUP BY c.Region

HAVING SUM(o.Profit) < 10000

ORDER BY Total_Profit ASC;


-- =====================================================
-- 7. CATEGORY PERFORMANCE
-- =====================================================

SELECT
    Category,

    SUM(Sales) AS Total_Sales,

    SUM(Profit) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percentage

FROM Orders

GROUP BY Category

ORDER BY Total_Sales DESC;


-- =====================================================
-- 8. SEGMENT REVENUE CONTRIBUTION
-- =====================================================

SELECT
    c.Segment,

    SUM(o.Sales) AS Total_Revenue,

    ROUND(
        SUM(o.Sales) * 100.0 /
        (
            SELECT SUM(Sales)
            FROM Orders
        ),
        2
    ) AS Revenue_Contribution_Percentage

FROM Orders o

INNER JOIN Customers c
    ON o.Customer_ID = c.Customer_ID

GROUP BY c.Segment

ORDER BY Total_Revenue DESC;


-- =====================================================
-- 9. TOP 10 CUSTOMERS
-- =====================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,

    SUM(o.Sales) AS Total_Sales,

    SUM(o.Profit) AS Total_Profit,

    COUNT(DISTINCT o.Order_ID) AS Total_Orders

FROM Orders o

INNER JOIN Customers c
    ON o.Customer_ID = c.Customer_ID

GROUP BY
    c.Customer_ID,
    c.Customer_Name

ORDER BY Total_Sales DESC

LIMIT 10;


-- =====================================================
-- 10. DISCOUNT VS PROFIT ANALYSIS
-- =====================================================

SELECT

    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10
            THEN 'Low Discount'

        WHEN Discount > 0.10 AND Discount <= 0.20
            THEN 'Medium Discount'

        ELSE 'High Discount'

    END AS Discount_Group,

    COUNT(*) AS Total_Orders,

    SUM(Sales) AS Total_Sales,

    SUM(Profit) AS Total_Profit,

    AVG(Profit) AS Average_Profit

FROM Orders

GROUP BY

    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount > 0 AND Discount <= 0.10
            THEN 'Low Discount'

        WHEN Discount > 0.10 AND Discount <= 0.20
            THEN 'Medium Discount'

        ELSE 'High Discount'
    END

ORDER BY Average_Profit DESC;


-- =====================================================
-- 11. NEGATIVE PROFIT ORDERS
-- =====================================================

SELECT
    Order_ID,
    Customer_ID,
    Category,
    Sales,
    Profit,
    Discount

FROM Orders

WHERE Profit < 0

ORDER BY Profit ASC;


-- =====================================================
-- 12. EXECUTIVE SUMMARY
-- =====================================================

SELECT

    SUM(Sales) AS Total_Sales,

    SUM(Profit) AS Total_Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Percentage,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    COUNT(DISTINCT Customer_ID) AS Total_Customers

FROM Orders;
