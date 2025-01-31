-- Netflix Database Project

CREATE TABLE netflix_content
(
	show_id VARCHAR(30),         
    type VARCHAR(30),            
    title VARCHAR(300),           
    director VARCHAR(600),        
    casts VARCHAR(1500),          
    country VARCHAR(600),         
    date_added VARCHAR(50),      
    release_year INT,             
    rating VARCHAR(20),           
    duration VARCHAR(20),         
    listed_in VARCHAR(300),      
    description VARCHAR(1000)     
)

SELECT * FROM netflix_content

SELECT COUNT(*) as total_amount_of_content
FROM netflix_content

SELECT 
DISTINCT netflix_content.listed_in
FROM netflix_content


-- 1. Compare the number of Movies and TV Shows available on the platform.
SELECT type, COUNT(*) as total_content 
FROM netflix_content
GROUP BY type


-- 2. What is the most frequent rating for Movies and TV Shows separately?

-- this code showcases a ranking system of all the ratings and types

SELECT 
type,
rating, 
COUNT(*) AS rating_count,
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix_content
GROUP BY type, rating

-- this code showcases the most frequent rating for each type
SELECT
type,
rating
FROM
(
	SELECT 
	type,
	rating, 
	COUNT(*) AS rating_count,
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix_content
	GROUP BY type, rating) as t1
WHERE
	ranking = 1

-- 3. List all Movies released in the year 2021.



SELECT * FROM netflix_content
WHERE type = 'Movie'
AND 
release_year = 2021


-- 4. Which 5 countries produce the highest amount of content on the platform?
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as single_country, 
COUNT(*) as content_count
FROM netflix_content
GROUP BY single_country
Order by content_count DESC
LIMIT 5



-- 5. Which Movie has the longest runtime?
SELECT * FROM netflix_content
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix_content)


-- 6. Find all content added to the platform between 2012 and 2020.

SELECT *
FROM netflix_content
WHERE TO_DATE(date_added, 'Month DD, YYYY') BETWEEN '2012-01-01' AND '2020-12-31';


-- 7. How many Movies and TV Shows were directed by 'Christopher Nolan'?
SELECT * 
FROM netflix_content
WHERE director iLIKE '%Christopher Nolan%'


-- 8. List all TV Shows that have at least 3 seasons.
SELECT *
FROM netflix_content
WHERE 
    type = 'TV Show'
    AND
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 3;

-- 9. How many content items are there in each genre?
SELECT 
	COUNT(show_id) as total_content,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre
FROM netflix_content
GROUP BY 2


-- 10. Find the top 5 years with the highest average number of content releases in the UK.
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_content WHERE country = 'United Kingdom')::numeric * 100
	,2) as avg_content_per_year
	FROM netflix_content
WHERE country = 'United Kingdom'
GROUP BY 1

-- 11. List all Movies that belong to the 'Documentary' genre.
SELECT *
FROM netflix_content
WHERE listed_in ILIKE '%documentaries%';

-- 12. How many content items do not have a director listed?

SELECT * FROM netflix_content
WHERE director IS NULL

-- 13. How many Movies has actor 'Arnold Schwarzenegger' appeared between 1990 and 2010
SELECT * 
FROM netflix_content
WHERE casts iLIKE '%Arnold Schwarzenegger%'
AND release_year between 1990 and 2010


-- 14. Who are the top 15 actors with the most appearances in American Movies?
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix_content
WHERE country ILIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15


-- 15. Categorize content as 'Violent' or 'Non-Violent' based on whether the description 
-- contains the words 'kill' or 'violence'. Count the number of items in each category.

WITH new_table
AS
(Select
*,
	CASE
	WHEN
		description ilike '%kill%' OR
		description ilike '%violence%' THEN 'Bad_Content'
		ELSE 'Good Content'
	END category 
FROM netflix_content
)
SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1

WHERE 
	description ILIKE '%kill%'

-- End of Project