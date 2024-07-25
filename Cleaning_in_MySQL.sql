
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns 

DROP TABLE layoffs_staging;

SET SQL_SAFE_UPDATES = 0;

SELECT * 
FROM layoffs;

-- CREATE TABLE LIKE layoffs 

CREATE TABLE layoffs_staging
LIKE layoffs;

-- COPY THE DATA FROM TABLE TO ANOTHER 

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

# WORKING ON DUPLICATE VALUES 

-- CHECK ON DUPLICATE VALUES BY USING ROW_NUMBER AND OVER

WITH DUPLICATE_CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY lay.company, lay.location, lay.industry, 
                            lay.total_laid_off, lay.percentage_laid_off, 
                            lay.funds_raised_millions, lay.country, `date`
           ) AS row_num
    FROM layoffs_staging AS lay
)
SELECT *
FROM DUPLICATE_CTE
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- NEED TO CREATE TABLE TO HOLD DATA OF row_num COLUMN TO DELETE THE DUPLICATE VALUES
DROP TABLE layoffs_staging2;
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2 
SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY lay.company, lay.location, lay.industry, 
                            lay.total_laid_off, lay.percentage_laid_off, 
                            lay.funds_raised_millions, lay.country, `date`
           ) AS row_num
    FROM layoffs_staging AS lay;
    
SELECT * 
FROM layoffs_staging2;
    
-- DELETE DUPLICATE VALUES

DELETE  
FROM layoffs_staging2
WHERE row_num > 1;

-- ENSURE THERE NO DUPLICATE VALUES

SELECT * 
FROM  layoffs_staging2
WHERE row_num > 1;

-- Done with duplicate values

# STANDARDIZE THE DATA
-- First Scan The Data Using DISTINCT If Find a miss or repeat value deal with it 
-- Second TRIM The Data To Get Rid Of White-Space 
-- Third UPDATE The Data With Value In Second
 
 SELECT * 
 FROM layoffs_staging2;
 
 
SELECT DISTINCT company
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company = TRIM(company);
 
SELECT DISTINCT location 
FROM layoffs_staging2
ORDER BY 1;

SELECT location, TRIM(location)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET location = TRIM(location);

SELECT DISTINCT industry, TRIM(industry)
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging2 
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2 
SET industry = TRIM(industry);


SELECT DISTINCT stage, TRIM(stage)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET stage = TRIM(stage);

SELECT DISTINCT country, TRIM(country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2 
SET country = TRIM(country);

# NULL VALUES OR BLANK VALUES


