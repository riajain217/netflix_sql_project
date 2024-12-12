-----netflix project
drop table if exists netflix

create table netflix
(show_id varchar(10),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(300)
)

select * from netflix
----------- 15 business problem--------
-----1.Count the Number of Movies vs TV Shows

select 
type, 
count(*)
from netflix
group by type

-------2. Find the Most Common Rating for Movies and TV Shows

select type,
rating
from

(select 
type, 
rating, 
count(rating) as no_times,
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by type,rating) as t1

where ranking = 1


-----3.List All Movies Released in a Specific Year (e.g., 2020)

select 
type,
title,
release_year
from netflix
where type = 'Movie' and release_year = 2020


-----4. Find the Top 5 Countries with the Most Content on Netflix

Select
unnest(string_to_array(country, ',')) as new_country,
count(show_id) as no_content
from netflix
group by country
order by no_content desc
limit 5

----5. Identify the Longest Movie

select * from netflix
where type = 'Movie' 
and 
duration = (select max (duration) from netflix)


-----6. Find Content Added in the Last 5 Years


select *
from netflix
where to_date(date_added,'Month DD, YYYY') >= current_date - interval '5 years'


----7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select title,new_director from 
(select title,
unnest(string_to_array(director, ',')) as new_director
from netflix)
where new_director ='Rajiv Chilaka'

-----8. List All TV Shows with More Than 5 Seasons

select title,type,duration
from netflix
where type = 'TV Show' 
and split_part(duration,' ',1)::int > 5

----9. Count the Number of Content Items in Each Genre

select
unnest(string_to_array(listed_in, ',')) as genre,
count(show_id) as total_count
from netflix
group by genre


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select
extract(year from to_date(date_added,'month DD,YYYY')) as year,
count(*) as yearly_content,
round
(count(*):: numeric/(select count(*) from netflix where country = 'India')::numeric *100,2)
as avg_content
from netflix
where country = 'India'
group by 1
order by avg_content desc
limit 5


----11. List all movies that are documentaries

select show_id,type,listed_in
from netflix
where type = 'Movie'
and
listed_in ilike '%Documentaries%'


-- 12. Find all content without a director

select *
from netflix
where director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where casts ilike '%Salman Khan%'
and release_year > extract(year from current_date) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


select type,
unnest(string_to_array(casts, ',')) as actors,
count(*)
from netflix
where type = 'Movie'
and
country ilike '%India'
group by 1,2
order by 3 desc
limit 10




/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

with new_table
as
(select *,
case
when description ilike '%kill%'
or
description ilike '%violence%' then 'Bad_content'
else 'good_content'
end as category
from netflix)



select category,
count(*) as total_content
from new_table
group by 1




