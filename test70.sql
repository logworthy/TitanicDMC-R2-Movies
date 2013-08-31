drop table user_lookup70;
create table user_lookup70 as select * from user_lookup where (total-non_matches*1.0)/total >= 0.70;

drop function rate_film70(numeric, numeric);
CREATE OR REPLACE FUNCTION rate_film70(numeric, numeric) RETURNS numeric AS $$
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
        (total-non_matches*1.0)/total desc
        limit 1
) b
on
a.user_id = b.matching_user
where
a.film_id = $2
$$ LANGUAGE sql STABLE STRICT;

/* 40 min */
drop table train_score_v70;
create table train_score_v70 as
select a.*
	, rate_film70(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
	, coalesce(rate_film70(a.user_id, a.film_id), b.n_score) as n_score
from 
	ratings_train a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id;


select count(*) from train_score_v70 where abs(n_rating - n_score1) < abs(n_rating - n_score2)
/* 25460 */
select count(*) from train_score_v70 where abs(n_rating - n_score1) > abs(n_rating - n_score2)
/* 34534 */

select count(*) from train_score_v70 where n_score2 = n_score
select count(*) from train_score_v70 where n_score1 = n_score
select * from train_score_v70

select sum(least(abs(n_rating-n_score1), abs(n_rating-n_score2))) from train_score_v70
select sum(least(abs(n_rating-n_score1), abs(n_rating-n_score2))) from train_score_v70a
select sum(abs(n_rating-n_score)) from train_score_v70
/* 44806 */
select sum(abs(n_rating-coalesce(n_score1, n_score2))) from train_score_v95
/* 45892 */

select a.*, round(n_score2, 0) as n_score3 from train_score_v70 a
select sum(abs(n_rating-round(n_score2,0))) from train_score_v70

select n_score1, count(*) from train_score_v2



drop table user_film_avg_test;
create table user_film_avg_test as
with film_avg as
(
select film_id, avg(n_rating) as n_score from ratings_train group by film_id
),
user_avg as
(
select user_id, avg(n_rating) as n_score from ratings_train group by user_id
),
group_avg as
(
select avg(n_rating) as n_score from ratings_train
)

select
a.user_id, a.film_id,
case
when c.n_score is not null and b.n_score is not null then
(b.n_score + c.n_score)/2.0
when c.n_score is not null or b.n_score is not null then
coalesce(b.n_score, c.n_score)
else d.n_score end as n_score
from
ratings_test a
left join
film_avg b
on a.film_id = b.film_id
left join
user_avg c
on a.user_id = c.user_id
cross join
group_avg d;

select count(*) from ratings_test



drop table test_score_v70;
create table test_score_v70 as
select a.*
	, rate_film70(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
from 
	ratings_test a
	, user_film_avg_test b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id;


select * from test_score_v70

drop table test_score_v70_final;
create table test_score_v70_final as
select 
	user_id
	, film_id
	, case 
	     when n_score1 in (1,2,3) then floor(n_score2)
	     when n_score1 in (4,5) then ceil(n_score2)
	     else round(n_score2,0) 
	end as n_rating
from test_score_v70
order by 
	user_id
	, film_id

select * from test_score_v70_final

create table test_score_v70_verify as
select 
	user_id
	, film_id
	, round(n_score2,0) as n_rating
from test_score_v70
order by 
	user_id
	, film_id

select count(n_rating), sum(n_rating), sum(user_id), sum(film_id) from test_score_v70_final
union
select count(n_rating), sum(n_rating), sum(user_id), sum(film_id) from test_score_v70_verify

select
	count(*)
	, sum(case when a.n_rating = b.n_rating then 1 else 0 end) as matches
	,  sum(case when a.n_rating <> b.n_rating then 1 else 0 end) as non_matches
from
	test_score_v70_final a
inner join
	test_score_v70_verify b
on
	a.user_id = b.user_id
	and a.film_id = b.film_id


	select * from test_score_v70_final

copy test_score_v70_final
to '/home/anon/TitanicDMC-R2-Movies/Ratings_Test_Final.csv'
CSV HEADER;
