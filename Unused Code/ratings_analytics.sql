/** META analytics
to get an idea of how complete our data is
how many films have ratings, whats the average number of ratings per film
etc **/

/* ratings per film - train*/
select 'ratings per film' as metric, min(k_ratings), max(k_ratings), avg(k_ratings), stddev(k_ratings) 
from (select film_id, count(*) as k_ratings from flat_train group by film_id) a

union
/* ratings per user - train*/
select 'ratings per user' as metric, min(k_ratings), max(k_ratings), avg(k_ratings), stddev(k_ratings) 
from (select user_id, count(*) as k_ratings from flat_train group by user_id) a

union
/* how many of the films in test have been rated by others?
   how many of the users in test have been rated by others?
*/
select 'train ratings per test film' as metric, min(k_ratings), max(k_ratings), avg(k_ratings), stddev(k_ratings) 
from (
	select 
		a.film_id,
		coalesce(b.k_ratings, 0) as k_ratings
	from
		ratings_test a
		left join
		(select film_id, count(*) as k_ratings from ratings_train group by film_id) b
		on a.film_id = b.film_id
) c
;

/* how many films weren't rated at all in train? */
select count(distinct b.film_id) from (select distinct film_id from ratings_train) a, (select distinct film_id from ratings_test) b where a.film_id = b.film_id
union all
select count(distinct film_id) from ratings_test;

/* how many users and films are we talking about? */
select count(distinct user_id) from users
union all
select count(distinct user_id) from ratings_train
union all
select count(distinct user_id) from ratings_test;

select count(distinct film_id) from movies 
union all
select count(distinct film_id) from ratings_train
union all
select count(distinct film_id) from ratings_test;
