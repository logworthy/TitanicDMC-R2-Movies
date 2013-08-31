
drop function rate_film70a(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film70a(numeric, numeric) RETURNS numeric AS $$
select a.n_rating
from
ratings_train a
inner join
(
        /* best match from users who also rated the film */
        select matching_user from user_lookup70 where user_id = $1 and
        count_bits(
        (film_bitmask($2)::bit(1682) & matchstring::bit(1682))::text
        ) = 1
        order by 
        (total-non_matches*1.0)/total
        * (1-(1/(5^(total/4)))) desc
        limit 1
) b
on
a.user_id = b.matching_user
where
a.film_id = $2
$$ LANGUAGE sql STABLE STRICT;

drop table train_score_v70a;
create table train_score_v70a as
select a.*
	, rate_film70a(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
from 
	ratings_train a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id;


create table test_score_v70 as
select a.*
	, rate_film70(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
from 
	ratings_test a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id;

select * from test_score_v70
select * from ratings_test

