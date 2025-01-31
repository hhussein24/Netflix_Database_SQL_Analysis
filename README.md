# Netflix_Database_SQL_Analysis

## Overview
This project is designed to demonstrate my expertise in SQL by analyzing Netflix's content library using advanced database queries and analytical techniques. Through this analysis, I showcase:

✅ SQL Proficiency – Implementing CRUD operations, filtering, aggregation, and complex analytical queries to extract meaningful insights.
✅ Data Cleaning & Transformation – Utilizing functions like UNNEST(), STRING_TO_ARRAY(), and SPLIT_PART() to structure and clean raw data effectively.
✅ Analytical Thinking – Identifying key trends in content production, actor appearances, and content categorization to provide strategic insights.
✅ Advanced SQL Functions – Leveraging window functions (RANK()), CTEs (WITH), date conversions (TO_DATE()), and conditional logic (CASE) to enhance data analysis.
✅ Business-Relevant Insights – Extracting valuable information on content distribution, ratings, and market trends, aligning data findings with business decision-making.

This project demonstrates my ability to work with real-world datasets, uncover trends, and provide actionable insights using SQL, making it a strong addition to my data analytics portfolio. 🚀

## Objectives

Content Distribution & Trends
Assess the balance between movies and TV shows, identifying content type trends over time.
Analyze the growth of content additions from 2010 to the present, highlighting peak production years.
Determine the top-producing countries and their contribution to Netflix’s global library.
Genre & Audience Insights
Identify the most popular genres and their prevalence in different regions.
Examine content ratings to understand audience segmentation across age groups.
Compare the distribution of documentary vs. non-documentary content across different countries.
Content Duration & Viewing Experience
Analyze the runtime distribution of movies and season counts of TV shows.
Identify outliers in duration, including the longest and shortest movies or series.
Investigate whether certain genres tend to have longer or shorter average runtimes.
Director & Actor Contributions
Rank directors based on the number of projects they have on the platform.
Identify the most frequently featured actors across Netflix's content library.
Explore the impact of renowned directors (e.g., Christopher Nolan) on Netflix’s catalog.
Market-Specific Analysis
Determine the top five countries with the highest volume of exclusive content.
Compare the release patterns of movies and TV shows in the U.S. vs. international markets.
Analyze trends in content ratings and genre preferences per country.
Content Categorization & Sentiment Analysis
Classify content into "Violent" vs. "Non-Violent" based on description keywords.
Identify common themes and keywords used in content descriptions.
Explore whether certain ratings (e.g., TV-MA, R) correlate with specific content themes.
Business & Platform Strategy Insights
Assess whether Netflix prioritizes quantity over quality by analyzing production trends.
Investigate the relationship between content release trends and major Netflix business events.
Explore how regional licensing strategies influence Netflix’s content availability.


## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Table

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Compare the number of Movies and TV Shows available on the platform.

```sql
SELECT type, COUNT(*) as total_content 
FROM netflix_content
GROUP BY type;
```

### 2. What is the most frequent rating for Movies and TV Shows separately?

this code showcases a ranking system of all the ratings and types
```sql
SELECT 
type,
rating, 
COUNT(*) AS rating_count,
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix_content
GROUP BY type, rating
```
**This code showcases the most frequent rating for each type**


```sql
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
```

### 3. List all Movies released in the year 2021.

```SELECT * FROM netflix_content
WHERE type = 'Movie'
AND 
release_year = 2021
```

### 4. Which 5 countries produce the highest amount of content on the platform?

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as single_country, 
COUNT(*) as content_count
FROM netflix_content
GROUP BY single_country
Order by content_count DESC
LIMIT 5
```

### 5. Which Movie has the longest runtime?

```sql
SELECT * FROM netflix_content
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix_content)
```

### 6. Find all content added to the platform between 2012 and 2020.

```sql
SELECT *
FROM netflix_content
WHERE TO_DATE(date_added, 'Month DD, YYYY') BETWEEN '2012-01-01' AND '2020-12-31';
```

### 7. How many Movies and TV Shows were directed by 'Christopher Nolan'?

```sql
SELECT * 
FROM netflix_content
WHERE director iLIKE '%Christopher Nolan%'
```

### 8. List all TV Shows that have at least 3 seasons.

```sql
SELECT *
FROM netflix_content
WHERE 
    type = 'TV Show'
    AND
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 3;
```

### 9. How many content items are there in each genre?

```sql
SELECT 
	COUNT(show_id) as total_content,
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre
FROM netflix_content
GROUP BY 2
```

### 10.Find the top 5 years with the highest average number of content releases in the UK.

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_content WHERE country = 'United Kingdom')::numeric * 100
	,2) as avg_content_per_year
	FROM netflix_content
WHERE country = 'United Kingdom'
GROUP BY 1
```

### 11. List all Movies that belong to the 'Documentary' genre.

```sql
SELECT *
FROM netflix_content
WHERE listed_in ILIKE '%documentaries%';
```

### 12. How many content items do not have a director listed?

```sql
SELECT * FROM netflix_content
WHERE director IS NULL
```

### 13. How many Movies has actor 'Arnold Schwarzenegger' appeared between 1990 and 2010

```sql
SELECT * 
FROM netflix_content
WHERE casts iLIKE '%Arnold Schwarzenegger%'
AND release_year between 1990 and 2010;
```

### 14. Who are the top 15 actors with the most appearances in American Movies?

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix_content
WHERE country ILIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 15
```

### 15. Categorize content as 'Violent' or 'Non-Violent' based on whether the description contains the words 'kill' or 'violence'. Count the number of items in each category.


```sql
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

```


## Findings and Conclusion

1. Content Distribution & Trends
Netflix's library is movie-heavy, with films outnumbering TV shows.
Content production peaked between 2015 and 2020, aligning with Netflix’s global expansion.
The United States, India, and the United Kingdom produce the highest volume of content.
2. Genre & Audience Preferences
Drama, Documentary, and Comedy are the most popular genres.
TV-MA and TV-14 are the most frequent content ratings, indicating a preference for mature audiences.
A large share of documentaries originates from the U.S. and U.K., reflecting strong consumer demand for factual content.
3. Content Duration & Viewing Patterns
The longest movies on Netflix significantly exceed the average runtime.
TV shows with three or more seasons are rare, suggesting many series are short-lived or designed as limited series.
4. Director & Actor Contributions
Christopher Nolan and other high-profile directors have a limited but impactful presence on Netflix.
Action, thriller, and drama actors appear frequently, suggesting these genres are key to audience engagement.
5. Business & Platform Strategy
Many Netflix titles lack a listed director, particularly in documentaries and reality TV.
Content growth peaked before the pandemic, but Netflix had already ramped up its library.
The U.K. maintains a steady content addition rate, indicating consistent investment.
Crime and action-oriented content dominate based on a classification of violent vs. non-violent descriptions.
##Conclusion
✔ Netflix prioritizes movies over TV shows, favoring high-engagement genres like drama, documentary, and comedy.
✔ The U.S., India, and the U.K. drive Netflix’s content supply, influencing global streaming trends.
✔ Short-form content dominates, reinforcing Netflix’s binge-watch culture and quick engagement strategy.
✔ Mature-rated content (TV-MA, TV-14) is most common, showing Netflix’s focus on adult-oriented entertainment.
✔ Recognizable actors and directors drive popularity, confirming Netflix’s reliance on star-driven content marketing.
✔ Documentaries and reality TV have a decentralized production model, which explains why many titles lack credited directors.
✔ Netflix's content decisions align with audience retention strategies, favoring crime, action, and thrillers to maintain viewer interest.


This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

