-- Data Cleaning

SELECT*
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data: Issues such as spelling
-- 3. Look at Null or blank values: populate that if necessary
-- 4. Remove columns and rows that aren't necessary

-- Copy of raw data (layoffs to layoffs_staging)
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT*
FROM layoffs_staging;

INSERT layoffs_staging
SELECT*
FROM layoffs;


-- 1. Removing Duplicates

SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;


-- Check duplicates:
SELECT*
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num >1;


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


SELECT*
FROM layoffs_staging2
WHERE row_num >1;

INSERT INTO layoffs_staging2
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;



DELETE
FROM layoffs_staging2
WHERE row_num >1;
SELECT*
FROM layoffs_staging2
WHERE row_num >1
;

-- 2. Standardizing Data:

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT industry
FROM layoffs_staging2;


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- Updating them all to be "Crypto":
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Updating country: 2 Methods
-- Method 1: Gets rid of spaces and period and everything else after "United States"
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'
;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Method 2: Doesn't get rid of blank spaces, just removes the period at the end.
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country;

-- Time series

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y')
;

SELECT `date`
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Fix Nulls and blanks

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL
;

 
 UPDATE layoffs_staging2
 SET industry = NULL
 WHERE industry = '';
 
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

-- 4. Remove columns and rows:

SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_staging2;

-- Get rid of last column: row_num

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
