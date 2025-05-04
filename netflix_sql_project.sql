-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC


-- 6. Find content added in the last 5 years
SELECT
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM
(

SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) as director_name
FROM 
netflix
)
WHERE 
	director_name = 'Rajiv Chilaka'



-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

---QUESTION : find the number of content items in each genre


select   
unnest(string_to_array(listed_in , ',')) as genre,
count(show_id)
from netflix
group by genre;


--QUESTION -- find each year and the average number of content released by india on netflix and also return 
           -- top 5 years with hightest average content released 

select 
extract(year from to_date(date_added , 'Month DD , YYYY')) AS year, 
count(*),
count(*)::numeric/(select count(*) from netflix where country like '%India%') *100 as average
from netflix 
where country like '%India%'
group by 1

--Question -- list all the movies that are documentaries

select listed_in, title from netflix
where listed_in like '%Documentaries%'

--QUESTION -- select all the movies without director


select * from netflix 
where director isnull

--question -- find in howmany movies actor 'salman khan' appeared in last 10 years 


select * from netflix 
where casts like '%Salman Khan%' 
and extract(year from current_date)-release_year <=10

--QUESTION : find top 10 actors who has appeared in highest number of movies produced in india


select 
unnest(string_to_array(casts,',')), count(*)
from netflix
where country like '%India%'
group by 1
order by 2 desc
limit 10;

--QUESTION : catogerise the content based on the keys words  "kill" and "violence " in the description 
           --label this keyword as 'bad' and all other as 'good' and acount how many items falls into each 
		   -- catogery


with cte as 
(select *,
case 
when description Ilike '%kill%' or
      description ilike '%violence%' then 'bad'
	  else 'good'
	  end as catogery 
from netflix)
select catogery , count(*) 
from cte 
group by catogery