/* ratings per film - train*/
select occupation, min(n_rating), max(n_rating), avg(n_rating), stddev(n_rating), 
count(*) as k_ratings, count(distinct user_id) as k_users, count(distinct film_id) as k_films,  
count(distinct film_id)/count(distinct user_id) as films_per_user
from flat_train group by occupation;

