USE PrestigeMotors;
GO

-- Check the number of imported deals
SELECT COUNT(*) AS Total_deals
FROM dbo.Deals;

-- Preview the first 10 deals
SELECT TOP (10) *
FROM dbo.Deals
ORDER BY Deal_ID;

-- Count deals and total their value by stage
SELECT
    Deal_stage,
    COUNT(*) AS Number_of_deals,
    SUM(Amount_USD) AS Total_value_USD
FROM dbo.Deals
GROUP BY Deal_stage
ORDER BY Number_of_deals DESC;

-- Compare completed sales by inquiry source
SELECT
    Inquiry_source,
    COUNT(*) AS Won_deals,
    SUM(Amount_USD) AS Won_sales_USD
FROM dbo.Deals
WHERE Deal_stage = 'Closed Won'
GROUP BY Inquiry_source
ORDER BY Won_sales_USD DESC;

-- Compare win rates among closed deals
SELECT
    Inquiry_source,
    COUNT(*) AS Closed_deals,
    SUM(CASE WHEN Deal_stage = 'Closed Won'
             THEN 1 ELSE 0 END) AS Won_deals,
    CAST(
        100.0 * SUM(CASE WHEN Deal_stage = 'Closed Won'
                         THEN 1 ELSE 0 END) / COUNT(*)
        AS DECIMAL(5,1)
    ) AS Win_rate_percent
FROM dbo.Deals
WHERE Deal_stage IN ('Closed Won', 'Closed Lost')
GROUP BY Inquiry_source
ORDER BY Win_rate_percent DESC;

-- Average calendar days from inquiry to won sale
SELECT
    COUNT(*) AS Won_deals,
    CAST(
        AVG(CAST(
            DATEDIFF(DAY, Inquiry_date, Outcome_date)
            AS DECIMAL(10,2)
        ))
        AS DECIMAL(10,1)
    ) AS Average_days_to_win
FROM dbo.Deals
WHERE Deal_stage = 'Closed Won';

-- Monthly sales by outcome month
SELECT
    CONVERT(CHAR(7), Outcome_date, 120) AS Sales_month,
    COUNT(*) AS Won_deals,
    SUM(Amount_USD) AS Won_sales_USD
FROM dbo.Deals
WHERE Deal_stage = 'Closed Won'
GROUP BY CONVERT(CHAR(7), Outcome_date, 120)
ORDER BY Sales_month;

-- Count lost deals by reason
SELECT
    Loss_reason,
    COUNT(*) AS Lost_deals,
    CAST(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM dbo.Deals
         WHERE Deal_stage = 'Closed Lost')
        AS DECIMAL(5,1)
    ) AS Share_of_losses_percent
FROM dbo.Deals
WHERE Deal_stage = 'Closed Lost'
GROUP BY Loss_reason
ORDER BY Lost_deals DESC;

-- Top five October offers by value, as of 30 September 2026
SELECT TOP (5)
    Deal_ID,
    Vehicle_brand,
    Vehicle_model,
    Amount_USD,
    Expected_close_date,
    Inquiry_source
FROM dbo.Deals
WHERE Deal_stage = 'Offer Sent'
  AND Expected_close_date >= '20261001'
  AND Expected_close_date < '20261101'
ORDER BY Amount_USD DESC, Deal_ID;

-- Count open opportunities and total their proposed value
SELECT
    COUNT(*) AS Open_deals,
    SUM(Amount_USD) AS Open_pipeline_USD
FROM dbo.Deals
WHERE Deal_stage IN (
    'New Inquiry',
    'Qualified Buyer',
    'Test Drive Scheduled',
    'Test Drive Completed',
    'Offer Sent'
);