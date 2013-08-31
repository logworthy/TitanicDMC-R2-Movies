drop table user_lookup80;
create table user_lookup80 as select * from user_lookup where (total-non_matches*1.0)/total >= 0.80;

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

/* 40 min */
drop table train_score_v80;
create table train_score_v80 as
select a.*
	, rate_film80(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
	, coalesce(rate_film80(a.user_id, a.film_id), b.n_score) as n_score
from 
	ratings_train a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id;


select count(*) from train_score_v95 where abs(n_rating - n_score1) < abs(n_rating - n_score2)
/* 25460 */
select count(*) from train_score_v95 where abs(n_rating - n_score1) > abs(n_rating - n_score2)
/* 34534 */

select count(*) from train_score_v95 where n_score2 <> n_score

select sum(least(abs(n_rating-n_score1), abs(n_rating-n_score2))) from train_score_v80
select sum(abs(n_rating-n_score)) from train_score_v80
/* 44806 */
select sum(abs(n_rating-coalesce(n_score1, n_score2))) from train_score_v95
/* 45892 */

