-- =======================================================================
-- Project : Unemployment Analysis (PLFS 2023-24)
-- =======================================================================

-- =======================================================================
-- SETUP PROCEDURE
-- =======================================================================

-- Step 1: Created PostgreSQL database in pgAdmin
--         Database Name: unemployment_analysis

-- Step 2: Imported CSV files as tables in pgAdmin
--         Right click database → Import/Export Data
--         state_data.csv    → table: unemployment_state
--         national_data.csv → table: unemployment_national

-- Step 3: Connected PostgreSQL to VS Code
--         Extension used : SQL Tool (by Matheus Teixeira)
--         Host           : localhost
--         Port           : 5432
--         Database       : unemployment_analysis
--         Username       : postgres

-- Step 4: Opened this .sql file in VS Code
--         Selected connection: unemployment_analysis
--         Execute SQL queries for analysis
-- =======================================================================
-- TABLES OVERVIEW
-- =======================================================================
-- state_data
--   Rows    : 963
--   Columns : year, state, sector, gender, indicator, value
--   Contains: 36 States/UTs level data

-- national_data
--   Rows    : 27
--   Columns : year, state, sector, gender, indicator, value
--   Contains: All India benchmark data

-- ============================================================
-- QUERIES INDEX
-- ============================================================

-- Q1  : National Benchmark Values
-- Q2  : State Rankings by UR
-- Q3  : States Above/Below National Benchmark
-- Q4  : Top 5 and Bottom 5 States
-- Q5  : Gender Gap in Unemployment Rate
-- Q6  : LFPR by Gender and Sector
-- Q7  : Rural vs Urban Unemployment
-- Q8  : Jobs Shortage States (High LFPR + High UR)
-- Q9  : Best and Worst Performing States (UR + WPR)

-- ============================================================
-- QUERIES START BELOW
-- ============================================================

-- ===============================================================
-- SECTION 1: National Benchmark
-- ===============================================================

SELECT 
    year,
    value AS national_unemployment_rate
FROM unemployment_national
WHERE indicator = 'Unemployment Rate'
AND gender = 'Person'
AND sector = 'Rural+Urban';

-- Insight:
-- The national unemployment rate stands at 3.2% for 2023-24.
-- This serves as a baseline benchmark to evaluate whether individual states
-- are performing above or below the national average.

-- ===============================================================
-- SECTION 2: STATE RANKING BY UNEMPLOYMENT RATE 
-- ==================================================================

SELECT 
    state,
    VALUE AS unemployment_rate
FROM unemployment_state
WHERE indicator = 'Unemployment Rate'
AND gender = 'Person'
AND sector = 'Rural+Urban'
ORDER BY VALUE DESC;

-- Insight:
-- Lakshadweep (11.9%) is significantly above the national average of 3.2%,
-- while Madhya Pradesh (1.0%) performs well below the benchmark,
-- highlighting wide regional disparities in unemployment.

-- ==================================================================
-- SECTION 3: STATES ABOVE/BELOW NATIONAL BENCHMARK
-- ==================================================================

SELECT 
    s.state,
    s.value AS state_ur,
    n.value AS national_ur,
ROUND((s.value - n.value)::numeric, 2) AS difference
FROM unemployment_state s
JOIN unemployment_national n
ON s.indicator = n.indicator
AND s.gender = n.gender
AND s.sector = n.sector
AND s.year = n.year
WHERE s.indicator = 'Unemployment Rate'
AND s.gender = 'Person'
AND s.sector = 'Rural+Urban'
ORDER BY ROUND((s.value - n.value)::numeric, 2) DESC;

-- Insight:
-- There is a wide disparity in unemployment rates across states.
-- Lakshadweep (+8.7%) and Andaman & Nicobar (+8.6%) show significantly higher
-- unemployment compared to the national average of 3.2%.
-- In contrast, states like Madhya Pradesh (-2.2%) and Gujarat (-2.1%)
-- perform considerably better than the national benchmark.

-- This indicates strong regional variation in employment conditions across India.
-- Union Territories and smaller regions tend to exhibit higher unemployment rates,
-- possibly due to limited economic diversification and smaller labor markets.

-- ==================================================================
-- SECTION 4: TOP 5 AND BOTTOM 5 STATES BY UNEMPLOYMENT RATE
-- ==================================================================

-- Top 5 states by Unemployment Rate
SELECT 
    state,
    VALUE AS unemployment_rate
    FROM unemployment_state
    WHERE indicator = 'Unemployment Rate'
    AND gender = 'Person'
    AND sector = 'Rural+Urban'
    ORDER BY value DESC
    LIMIT 5;

-- Bottom 5 states by Unemployment Rate
SELECT 
    state,
    VALUE AS unemployment_rate
    FROM unemployment_state
    WHERE indicator = 'Unemployment Rate'
    AND gender = 'Person'
    AND sector = 'Rural+Urban'
    ORDER BY value ASC
    LIMIT 5;

-- Insight:
-- The top 5 states with the highest unemployment rates include Lakshadweep, Andaman & Nicobar Islands,
-- Goa, Kerala, and Nagaland, all significantly above the national average of 3.2%.
-- These are mostly smaller regions or Union Territories, indicating limited labor market opportunities.

-- Kerala stands out as an exception among larger states, with a relatively high unemployment rate of 7.2%,
-- suggesting structural factors such as higher education levels and job-market mismatch.

-- The bottom 5 states, including Madhya Pradesh, Gujarat, Jharkhand, Tripura, and Delhi,
-- show significantly lower unemployment rates, reflecting comparatively better employment absorption.

-- This highlights that while smaller regions often show extreme values, some states like Tripura
-- demonstrate that lower unemployment is also possible, indicating regional diversity in employment conditions.

-- ==================================================================
-- SECTION 5: GENDER GAP IN UNEMPLOYMENT RATE
-- ==================================================================

SELECT 
    sector,
    ROUND(AVG(CASE WHEN gender = 'Male' THEN value END)::numeric, 2) AS male_ur,
    ROUND(AVG(CASE WHEN gender = 'Female' THEN value END)::numeric, 2) AS female_ur
FROM unemployment_state
WHERE indicator = 'Unemployment Rate'
GROUP BY sector
ORDER BY sector;

-- Insight:
-- Female unemployment rates are consistently higher than male across both rural and urban sectors.
-- The disparity is significantly more pronounced in urban areas, where female unemployment (11.29%)
-- is more than double that of rural female unemployment (5.72%).

-- While male unemployment increases moderately from rural (3.22%) to urban (5.12%),
-- the sharp rise in female unemployment suggests stronger barriers for women in urban labor markets.

-- This indicates a substantial gender gap, particularly in urban regions, highlighting structural challenges
-- in employment accessibility for women.

-- The higher female unemployment in urban areas may indicate greater competition,
-- skill mismatch, or socio-economic barriers affecting women's participation in formal employment.


-- ==================================================================
-- SECTION 6: LFPR BY GENDER AND SECTOR
-- ==================================================================

SELECT 
    sector,
    gender,
    ROUND(AVG(value)::numeric, 2) AS avg_lfpr
FROM unemployment_state
WHERE indicator = 'Labour Force Participation Rate'
AND gender IN ('Male', 'Female')
GROUP BY sector, gender
ORDER BY sector, gender;

-- Insight: 
-- Labour Force Participation Rate (LFPR) is significantly higher for males than females
-- across all sectors, indicating a substantial gender gap in workforce participation.

-- Female participation drops sharply from rural (51.01%) to urban areas (31.19%),
-- suggesting stronger barriers for women entering the urban labor market.

-- In contrast, male participation remains consistently high across both rural and urban sectors
-- (approximately 75–79%), indicating stable workforce engagement among men.

-- At the same time, female unemployment rates are higher than males in both rural and urban areas,
-- with the disparity being significantly more pronounced in urban regions.

-- This reveals a dual challenge for women:
-- (1) Lower participation in the workforce
-- (2) Higher unemployment among those who do participate

-- Overall, the analysis highlights structural gender disparities in India's labor market,
-- particularly in urban areas where both participation is low and unemployment is high for women.

-- ==================================================================
-- SECTION 7: RURAL VS URBAN UNEMPLOYMENT RATE
-- ==================================================================

SELECT 
    sector,
    ROUND(AVG(value)::numeric, 2) AS avg_unemployment_rate
FROM unemployment_state
WHERE indicator = 'Unemployment Rate'
AND gender = 'Person'
AND sector IN ('Rural', 'Urban')
GROUP BY sector
ORDER BY avg_unemployment_rate DESC;

-- Insight:
-- Urban unemployment rate (6.91%) is significantly higher than rural unemployment (3.75%),
-- indicating greater job competition and employment challenges in urban areas.

-- This suggests that while urban regions may offer more opportunities,
-- they also face higher labour supply pressure, leading to increased unemployment.

-- In contrast, lower rural unemployment may reflect either better absorption
-- in informal or agricultural work, or lower participation in the labour market.

-- Lower rural unemployment does not necessarily indicate better employment conditions,
-- as it may be influenced by informal employment and lower workforce participation.

-- ==================================================================
-- SECTION 8: JOB SHORTAGE STATES (HIGH LFPR + HIGH UNEMPLOYMENT)
-- ==================================================================

-- Q8: Job Shortage States 

SELECT *
FROM (
    SELECT 
        state,
        AVG(CASE WHEN indicator = 'Labour Force Participation Rate' THEN value END) AS lfpr,
        AVG(CASE WHEN indicator = 'Unemployment Rate' THEN value END) AS unemployment_rate
    FROM unemployment_state
    WHERE sector = 'Rural+Urban'
    AND gender = 'Person'
    GROUP BY state
) result
WHERE lfpr > 60 AND unemployment_rate > 5;

-- Insight:
-- Several states, including Andaman & Nicobar Islands, Nagaland, and Meghalaya,
-- exhibit both high labour force participation and high unemployment rates,
-- indicating a significant mismatch between labour supply and job availability.

-- These regions show that a large proportion of the population is actively seeking employment,
-- but sufficient job opportunities are not available, leading to elevated unemployment levels.

-- The presence of multiple smaller and geographically constrained states in this group
-- suggests that limited economic diversification and regional constraints may contribute
-- to employment challenges.

-- Andaman & Nicobar Islands stands out as the most critical case,
-- with both high participation (65.7%) and extremely high unemployment (11.8%),
-- highlighting severe labour market stress.

-- ==================================================================
-- SECTION 9: BEST AND WORST PERFORMING STATE (UR + WPR)
-- ==================================================================

-- 9A. Best States

SELECT *
FROM (
    SELECT 
        state,
        AVG(CASE WHEN indicator = 'Labour Force Participation Rate' THEN value END) AS lfpr,
        AVG(CASE WHEN indicator = 'Unemployment Rate' THEN value END) AS unemployment_rate
    FROM unemployment_state
    WHERE sector = 'Rural+Urban'
    AND gender = 'Person'
    GROUP BY state
) result
WHERE lfpr > 60 AND unemployment_rate < 3
ORDER BY unemployment_rate ASC;

-- 9B: Worst States

SELECT *
FROM (
    SELECT 
        state,
        AVG(CASE WHEN indicator = 'Labour Force Participation Rate' THEN value END) AS lfpr,
        AVG(CASE WHEN indicator = 'Unemployment Rate' THEN value END) AS unemployment_rate
    FROM unemployment_state
    WHERE sector = 'Rural+Urban'
    AND gender = 'Person'
    GROUP BY state
) result
WHERE lfpr < 50 AND unemployment_rate > 5
ORDER BY unemployment_rate DESC;

-- Note:
-- Thresholds are selected based on observed dataset distribution.
-- National unemployment rate (~3.2%) is used as a reference point.
-- LFPR thresholds are based on general participation trends across states.

-- Insight:
-- States such as Madhya Pradesh, Gujarat, and Jharkhand demonstrate strong labour market performance,
-- with high participation rates and low unemployment, indicating effective job absorption.

-- In contrast, Lakshadweep represents the weakest performing region,
-- with low participation and extremely high unemployment, reflecting both limited workforce engagement
-- and severe job scarcity.

-- This highlights significant regional disparities in labour market efficiency across India.


-- =======================================================================
-- SUMMARY INSIGHTS
-- =======================================================================

-- 1. National Benchmark
-- The overall unemployment rate in India is approximately 3.2%,
-- which serves as a benchmark for comparing state-level performance.

-- 2. State-Level Variation
-- There is significant variation across states. Lakshadweep (11.9%)
-- and Andaman & Nicobar Islands (11.8%) show extremely high unemployment,
-- while states like Madhya Pradesh (1.0%) and Gujarat (1.1%) demonstrate
-- much lower unemployment rates.

-- 3. Rural vs Urban Trends
-- Urban areas have higher unemployment (~6.9%) compared to rural areas (~3.7%),
-- indicating greater job competition and employment challenges in urban regions.

-- 4. Gender Gap in Unemployment
-- Female unemployment is significantly higher than male unemployment,
-- especially in urban areas where female unemployment exceeds 11%.
-- This highlights gender disparity in job access and opportunities.

-- 5. Labour Force Participation (LFPR)
-- Male participation remains consistently high (~75–80%),
-- while female participation is much lower, particularly in urban areas (~31%),
-- indicating lower workforce engagement among women.

-- 6. Job Shortage States (High LFPR + High UR)
-- States such as Nagaland, Meghalaya, and Jammu & Kashmir show both high participation
-- and high unemployment, indicating a mismatch between labour supply and job availability.

-- 7. Best Performing States
-- States like Madhya Pradesh, Gujarat, and Jharkhand exhibit strong labour market conditions,
-- with high participation and low unemployment, indicating efficient job absorption.

-- 8. Overall Conclusion
-- The analysis reveals significant regional and structural disparities in India’s labour market,
-- influenced by geography, gender, and urbanization.
