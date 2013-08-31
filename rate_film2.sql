/* 
	1.  see if there is a user in the lookup who has also rate the film
*/
drop function rate_film2(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film2(numeric, numeric) RETURNS numeric AS $$
select a.n_rating
from
ratings_train a
left join
(
	/* best match from users who also rated the film */
	select matching_user from user_lookup where user_id = $1 and 
	count_bits(
	(film_bitmask($2)::bit(1682) & matchstring::bit(1682))::text
	) = 1
	order by (total-non_matches*1.0)/total desc
	limit 1
) b
on
a.user_id = b.matching_user
where
a.film_id = $2 
$$ LANGUAGE sql STABLE STRICT;

drop function rate_film95(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film95(numeric, numeric) RETURNS numeric AS $$
select a.n_rating
from
ratings_train a
inner join
(
	/* best match from users who also rated the film */
	select matching_user from user_lookup95 where user_id = $1 and 
	count_bits(
	(film_bitmask($2)::bit(1682) & matchstring::bit(1682))::text
	) = 1
	order by (total-non_matches*1.0)/total desc
	limit 1
) b
on
a.user_id = b.matching_user
where
a.film_id = $2 
$$ LANGUAGE sql STABLE STRICT;

drop function rate_film80(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film80(numeric, numeric) RETURNS numeric AS $$
select a.n_rating
from
ratings_train a
inner join
(
	/* best match from users who also rated the film */
	select matching_user from user_lookup80 where user_id = $1 and 
	count_bits(
	(film_bitmask($2)::bit(1682) & matchstring::bit(1682))::text
	) = 1
	order by (total-non_matches*1.0)/total desc
	limit 1
) b
on
a.user_id = b.matching_user
where
a.film_id = $2 
$$ LANGUAGE sql STABLE STRICT;
