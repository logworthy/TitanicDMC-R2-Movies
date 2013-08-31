drop function rate_film(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film(numeric, numeric) RETURNS numeric AS $$
select a.n_rating
from
flat_train a,
(
	select a.user_id 
	from
	(select user_id, film_id from flat_train where user_id != $1 and film_id = $2) a
	inner join
	(select $1 as user_id, $2 as film_id) b 
	on a.film_id = b.film_id 
	order by compare_users(a.user_id, b.user_id) desc
	limit 1
) b
where
a.user_id = b.user_id
and a.film_id = $2 
$$ LANGUAGE sql STABLE STRICT;
