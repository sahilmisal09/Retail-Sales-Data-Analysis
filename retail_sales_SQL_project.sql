-- ============================================================
--   RETAIL SALES PROJECT — Complete SQL Query File
--   Database : sales_project
--   Tables   : stores, customers, products, inventory, sales_data
--   Author   : Mithun Verma
-- ============================================================

-- ─────────────────────────────────────────────────────────────
--  SECTION 0 — DATABASE & TABLE SETUP
-- ─────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS sales_project;
USE sales_project;

CREATE TABLE IF NOT EXISTS stores (
    Store_ID   VARCHAR(10)  PRIMARY KEY,
    Store_Name VARCHAR(100),
    City       VARCHAR(50),
    Region     VARCHAR(20),
    Manager    VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS customers (
    Customer_ID   VARCHAR(10)  PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Email         VARCHAR(100),
    Phone         VARCHAR(15),
    City          VARCHAR(50),
    Segment       VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS products (
    Product_ID   VARCHAR(10)  PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category     VARCHAR(50),
    Unit_Price   DECIMAL(10,2),
    Reorder_Level INT
);

CREATE TABLE IF NOT EXISTS inventory (
    Store_ID         VARCHAR(10),
    Product_ID       VARCHAR(10),
    Stock_Qty        INT,
    Reorder_Level    INT,
    Last_Restock_Date DATE,
    FOREIGN KEY (Store_ID)   REFERENCES stores(Store_ID),
    FOREIGN KEY (Product_ID) REFERENCES products(Product_ID)
);

CREATE TABLE IF NOT EXISTS sales_data (
    Transaction_ID  VARCHAR(20)   PRIMARY KEY,
    Date            DATE,
    Customer_ID     VARCHAR(10),
    Store_ID        VARCHAR(10),
    Product_ID      VARCHAR(10),
    Quantity        INT,
    Unit_Price      DECIMAL(10,2),
    Discount_Pct    DECIMAL(5,2),
    Gross_Amount    DECIMAL(10,2),
    Discount_Amount DECIMAL(10,2),
    Net_Amount      DECIMAL(10,2),
    Status          VARCHAR(20),
    Payment_Method  VARCHAR(30),
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Store_ID)    REFERENCES stores(Store_ID),
    FOREIGN KEY (Product_ID)  REFERENCES products(Product_ID)
);


-- ─────────────────────────────────────────────────────────────
--  SECTION 1 — BASIC / EASY QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q1: All customers from Delhi
SELECT *
FROM customers
WHERE City = 'Delhi';

-- Q2: Total unique customers who made a purchase
SELECT COUNT(DISTINCT Customer_ID) AS Unique_Customers
FROM sales_data;

-- Q3: Total Net Amount by product category
SELECT p.Category,
       ROUND(SUM(s.Net_Amount), 2) AS Total_Revenue
FROM sales_data s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

-- Q4: Transactions where Discount_Pct > 15%
SELECT *
FROM sales_data
WHERE Discount_Pct > 15;

-- Q5: Payment method with the most transactions
SELECT Payment_Method,
       COUNT(*) AS Transaction_Count
FROM sales_data
GROUP BY Payment_Method
ORDER BY Transaction_Count DESC
LIMIT 1;

-- Q6: Total number of transactions per order status
SELECT Status,
       COUNT(*) AS Count
FROM sales_data
GROUP BY Status
ORDER BY Count DESC;

-- Q7: All products in the 'Electronics' category
SELECT *
FROM products
WHERE Category = 'Electronics';

-- Q8: Products sorted by Unit_Price descending (top 10)
SELECT Product_Name, Category, Unit_Price
FROM products
ORDER BY Unit_Price DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
--  SECTION 2 — INTERMEDIATE QUERIES (GROUP BY / JOINS)
-- ─────────────────────────────────────────────────────────────

-- Q9: Top 5 best-selling products by quantity
SELECT p.Product_Name,
       SUM(s.Quantity) AS Total_Qty_Sold
FROM sales_data s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY Total_Qty_Sold DESC
LIMIT 5;

-- Q10: Monthly revenue trend (2023 and 2024 combined)
SELECT YEAR(Date)  AS Year,
       MONTH(Date) AS Month,
       ROUND(SUM(Net_Amount), 2) AS Monthly_Revenue
FROM sales_data
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

-- Q11: Store-wise total revenue with store names
SELECT st.Store_Name,
       st.City,
       st.Region,
       ROUND(SUM(s.Net_Amount), 2) AS Total_Revenue
FROM sales_data s
JOIN stores st ON s.Store_ID = st.Store_ID
GROUP BY st.Store_Name, st.City, st.Region
ORDER BY Total_Revenue DESC;

-- Q12: Customers whose total purchase value > ₹50,000
SELECT c.Customer_Name,
       c.City,
       c.Segment,
       ROUND(SUM(s.Net_Amount), 2) AS Total_Spend
FROM sales_data s
JOIN customers c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Name, c.City, c.Segment
HAVING Total_Spend > 50000
ORDER BY Total_Spend DESC;

-- Q13: Average order value by region
SELECT st.Region,
       ROUND(AVG(s.Net_Amount), 2) AS Avg_Order_Value
FROM sales_data s
JOIN stores st ON s.Store_ID = st.Store_ID
GROUP BY st.Region
ORDER BY Avg_Order_Value DESC;

-- Q14: Year-wise revenue comparison (2023 vs 2024)
SELECT YEAR(Date) AS Year,
       ROUND(SUM(Net_Amount), 2) AS Total_Revenue,
       COUNT(*)                  AS Total_Orders
FROM sales_data
GROUP BY YEAR(Date)
ORDER BY Year;

-- Q15: Customers who have made a Return
SELECT DISTINCT c.Customer_ID, c.Customer_Name, c.City, c.Segment
FROM sales_data s
JOIN customers c ON s.Customer_ID = c.Customer_ID
WHERE s.Status = 'Returned';

-- Q16: Revenue contribution % by product category
SELECT p.Category,
       ROUND(SUM(s.Net_Amount), 2)                                       AS Category_Revenue,
       ROUND(SUM(s.Net_Amount) / SUM(SUM(s.Net_Amount)) OVER () * 100, 2) AS Revenue_Pct
FROM sales_data s
JOIN products p ON s.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Category_Revenue DESC;

-- Q17: Month-over-month revenue growth (using LAG)
WITH monthly AS (
    SELECT YEAR(Date)  AS Yr,
           MONTH(Date) AS Mo,
           ROUND(SUM(Net_Amount), 2) AS Revenue
    FROM sales_data
    GROUP BY YEAR(Date), MONTH(Date)
)
SELECT Yr, Mo, Revenue,
       LAG(Revenue) OVER (ORDER BY Yr, Mo)                              AS Prev_Month_Revenue,
       ROUND((Revenue - LAG(Revenue) OVER (ORDER BY Yr, Mo))
             / LAG(Revenue) OVER (ORDER BY Yr, Mo) * 100, 2)           AS MoM_Growth_Pct
FROM monthly
ORDER BY Yr, Mo;


-- ─────────────────────────────────────────────────────────────
--  SECTION 3 — INVENTORY ANALYSIS
-- ─────────────────────────────────────────────────────────────

-- Q18: Products at or below reorder level (urgent restocking needed)
SELECT i.Store_ID,
       st.Store_Name,
       p.Product_Name,
       p.Category,
       i.Stock_Qty,
       i.Reorder_Level,
       (i.Reorder_Level - i.Stock_Qty) AS Shortage_Qty,
       i.Last_Restock_Date
FROM inventory i
JOIN stores   st ON i.Store_ID   = st.Store_ID
JOIN products p  ON i.Product_ID = p.Product_ID
WHERE i.Stock_Qty <= i.Reorder_Level
ORDER BY Shortage_Qty DESC;

-- Q19: Out-of-stock products
SELECT i.Store_ID, st.Store_Name, p.Product_Name, i.Stock_Qty, i.Last_Restock_Date
FROM inventory i
JOIN stores   st ON i.Store_ID   = st.Store_ID
JOIN products p  ON i.Product_ID = p.Product_ID
WHERE i.Stock_Qty = 0;

-- Q20: Store-wise total stock summary
SELECT i.Store_ID,
       st.Store_Name,
       st.Region,
       SUM(i.Stock_Qty) AS Total_Stock,
       COUNT(DISTINCT i.Product_ID) AS Products_Stocked
FROM inventory i
JOIN stores st ON i.Store_ID = st.Store_ID
GROUP BY i.Store_ID, st.Store_Name, st.Region
ORDER BY Total_Stock DESC;

-- Q21: Products not restocked in last 6 months (from latest date in data)
SELECT i.Store_ID, p.Product_Name, i.Stock_Qty, i.Last_Restock_Date
FROM inventory i
JOIN products p ON i.Product_ID = p.Product_ID
WHERE i.Last_Restock_Date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY i.Last_Restock_Date ASC;


-- ─────────────────────────────────────────────────────────────
--  SECTION 4 — ADVANCED / ANALYTICS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q22: Customer segmentation — RFM-style (Recency, Frequency, Monetary)
SELECT c.Customer_ID,
       c.Customer_Name,
       c.Segment,
       DATEDIFF(CURDATE(), MAX(s.Date))    AS Recency_Days,
       COUNT(s.Transaction_ID)             AS Frequency,
       ROUND(SUM(s.Net_Amount), 2)         AS Monetary
FROM sales_data s
JOIN customers c ON s.Customer_ID = c.Customer_ID
WHERE s.Status != 'Cancelled'
GROUP BY c.Customer_ID, c.Customer_Name, c.Segment
ORDER BY Monetary DESC
LIMIT 20;

-- Q23: Top performing store per region
WITH ranked AS (
    SELECT st.Region,
           st.Store_Name,
           ROUND(SUM(s.Net_Amount), 2) AS Revenue,
           RANK() OVER (PARTITION BY st.Region ORDER BY SUM(s.Net_Amount) DESC) AS rk
    FROM sales_data s
    JOIN stores st ON s.Store_ID = st.Store_ID
    GROUP BY st.Region, st.Store_Name
)
SELECT Region, Store_Name, Revenue
FROM ranked
WHERE rk = 1;

-- Q24: Running cumulative revenue over time
SELECT Date,
       ROUND(SUM(Net_Amount), 2)                    AS Daily_Revenue,
       ROUND(SUM(SUM(Net_Amount)) OVER
             (ORDER BY Date ROWS UNBOUNDED PRECEDING), 2) AS Cumulative_Revenue
FROM sales_data
GROUP BY Date
ORDER BY Date;

-- Q25: Product category performance by customer segment (crosstab style)
SELECT p.Category,
       c.Segment,
       ROUND(SUM(s.Net_Amount), 2) AS Revenue
FROM sales_data s
JOIN products   p ON s.Product_ID  = p.Product_ID
JOIN customers  c ON s.Customer_ID = c.Customer_ID
GROUP BY p.Category, c.Segment
ORDER BY p.Category, Revenue DESC;

-- Q26: Discount impact analysis — high vs low discount buckets
SELECT
    CASE
        WHEN Discount_Pct = 0       THEN 'No Discount'
        WHEN Discount_Pct <= 10     THEN '1–10%'
        WHEN Discount_Pct <= 20     THEN '11–20%'
        ELSE '21%+'
    END AS Discount_Bucket,
    COUNT(*)                        AS Transactions,
    ROUND(AVG(Net_Amount), 2)       AS Avg_Net_Amount,
    ROUND(SUM(Net_Amount), 2)       AS Total_Net_Amount
FROM sales_data
GROUP BY Discount_Bucket
ORDER BY Avg_Net_Amount DESC;

-- Q27: Repeat vs one-time customers
SELECT
    CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS Customer_Type,
    COUNT(*) AS Customer_Count
FROM (
    SELECT Customer_ID, COUNT(Transaction_ID) AS order_count
    FROM sales_data
    GROUP BY Customer_ID
) sub
GROUP BY Customer_Type;

-- Q28: Revenue by city (top 10 cities)
SELECT c.City,
       ROUND(SUM(s.Net_Amount), 2) AS Total_Revenue,
       COUNT(s.Transaction_ID)     AS Orders
FROM sales_data s
JOIN customers c ON s.Customer_ID = c.Customer_ID
GROUP BY c.City
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Q29: Cancellation rate by region
SELECT st.Region,
       COUNT(*)                                              AS Total_Orders,
       SUM(CASE WHEN s.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       ROUND(SUM(CASE WHEN s.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
             / COUNT(*), 2)                                  AS Cancellation_Rate_Pct
FROM sales_data s
JOIN stores st ON s.Store_ID = st.Store_ID
GROUP BY st.Region
ORDER BY Cancellation_Rate_Pct DESC;

-- Q30: Quarter-wise revenue (all years)
SELECT YEAR(Date)                       AS Year,
       QUARTER(Date)                    AS Quarter,
       ROUND(SUM(Net_Amount), 2)        AS Quarterly_Revenue,
       COUNT(Transaction_ID)            AS Orders
FROM sales_data
GROUP BY YEAR(Date), QUARTER(Date)
ORDER BY Year, Quarter;


-- ─────────────────────────────────────────────────────────────
--  SECTION 5 — VIEWS (reusable virtual tables)
-- ─────────────────────────────────────────────────────────────

-- View 1: Full enriched sales view
CREATE OR REPLACE VIEW vw_sales_enriched AS
SELECT s.Transaction_ID,
       s.Date,
       s.Quantity,
       s.Unit_Price,
       s.Discount_Pct,
       s.Gross_Amount,
       s.Discount_Amount,
       s.Net_Amount,
       s.Status,
       s.Payment_Method,
       c.Customer_Name,
       c.City      AS Customer_City,
       c.Segment,
       p.Product_Name,
       p.Category,
       st.Store_Name,
       st.Region
FROM sales_data s
JOIN customers c  ON s.Customer_ID = c.Customer_ID
JOIN products  p  ON s.Product_ID  = p.Product_ID
JOIN stores    st ON s.Store_ID    = st.Store_ID;

-- View 2: Inventory alert view
CREATE OR REPLACE VIEW vw_inventory_alerts AS
SELECT i.Store_ID,
       st.Store_Name,
       st.Region,
       p.Product_Name,
       p.Category,
       i.Stock_Qty,
       i.Reorder_Level,
       CASE WHEN i.Stock_Qty = 0 THEN 'OUT OF STOCK'
            WHEN i.Stock_Qty <= i.Reorder_Level THEN 'REORDER NOW'
            ELSE 'OK'
       END AS Stock_Status,
       i.Last_Restock_Date
FROM inventory i
JOIN stores   st ON i.Store_ID   = st.Store_ID
JOIN products p  ON i.Product_ID = p.Product_ID;

-- ─────────────────────────────────────────────────────────────
--  END OF FILE
-- ─────────────────────────────────────────────────────────────
