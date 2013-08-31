select * from percentile_counts

select min(maxp) from
(
select user1, max(percentile) as maxp from percentile_counts
group by user1
) b

select min(film_id), max(film_id), count(film_id) from movies

select film_id from movies

drop function film_bitmask(integer);
create or replace function film_bitmask(film_id numeric) returns text as 
$$
declare
  result text := '';
  i numeric := 0;
begin
  for i in 1..1682 loop
    if i = film_id then
	result := result || '1';
    else
	result := result || '0';
    end if;
  end loop;
  return result;
end;
$$ language plpgsql;

select 
	sum(user_id)
	from top_users
	where 
	count_bits(
	(film_bitmask(3)::bit(1682) & matchstring::bit(1682))::text
	) = 1

select sum(user_id) from ratings_train where film_id = 3
and user_id in (select user_id from top_users)


select a.*, (total-non_matches*1.0)/total from user_lookup a

select rate_film2(1,1683)

/* 4.3 hours */
create table train_score_v1 as
select a.*
	, rate_film2(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
	, coalesce(rate_film2(a.user_id, a.film_id), b.n_score) as n_score
from 
	ratings_train a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id


select * from train_score_v1
select count(*) from train_score_v1 where abs(n_rating - n_score1) < abs(n_rating - n_score2)
/* 25460 */
select count(*) from train_score_v1 where abs(n_rating - n_score1) > abs(n_rating - n_score2)
/* 34534 */

select count(*) from train_score_v1 where n_score1 <> n_score

select sum(least(abs(n_rating-n_score1), abs(n_rating-n_score2))) from train_score_v1



select count(*) from user_lookup
select max((total-non_matches*1.0)/total) from user_lookup

select * from user_lookup limit 100
 
/* 
   0.95 -   768
   0.90 -  1217
   0.85 -  2496
   0.80 -  5785
   0.75 -  9214
   0.70 - 14330
   0.65 - 21731
   0.60 - 29494
*/
select count(*) from user_lookup where (total-non_matches*1.0)/total >= 0.95

drop table user_lookup_95
create table user_lookup95 as select * from user_lookup where (total-non_matches*1.0)/total >= 0.95

/* 2 hours */
create table train_score_v95 as
select a.*
	, rate_film95(a.user_id, a.film_id) as n_score1
	, b.n_score as n_score2
	, coalesce(rate_film95(a.user_id, a.film_id), b.n_score) as n_score
from 
	ratings_train a
	, user_film_avg_train b
where
	a.user_id = b.user_id
	and a.film_id = b.film_id

2515
select count(*) from train_score_v95 where abs(n_rating - n_score1) < abs(n_rating - n_score2)
/* 25460 */
select count(*) from train_score_v95 where abs(n_rating - n_score1) > abs(n_rating - n_score2)
/* 34534 */

select count(*) from train_score_v95 where n_score2 <> n_score

select sum(least(abs(n_rating-n_score1), abs(n_rating-n_score2))) from train_score_v95
select sum(abs(n_rating-n_score)) from train_score_v95
select sum(abs(n_rating-coalesce(n_score1, n_score2))) from train_score_v95
/* 45892 */

select * from train_score_v95


select n_score1, count(*) from train_score_v1
group by n_score1 order by n_score1

select n_rating, count(*) from train_score_v1
group by n_rating order by n_rating

select 13015+19682+3701+7537+16065

/*
1;3701
2;7537
3;16065
4;19682
5;13015
*/

/*
1;3681
2;6924
3;16344
4;20399
5;12652
*/

select sum(abs(n_rating-round(n_score2,0))) from train_score_v1
select sum(abs(n_rating-round((n_score1+n_score2)/2.0,0))) from train_score_v1
select sum(abs(n_rating-round(n_score2,0))) from train_score_v1

select n_rating
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v1
group by
	n_rating


select n_score1, n_rating
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v1
group by
	n_score1, n_rating
order by
	n_score1, n_rating



select n_score1
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v1
group by
	n_score1


select n_score1
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v70
group by
	n_score1


select n_score1
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v80
group by
	n_score1



select n_score1
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - n_score2) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - n_score2) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v70
group by
	n_score1



select n_score1
	, sum(case when abs(n_rating - n_score1) < abs(n_rating - round(n_score2, 0)) then 1 else 0 end) as avg_worse
	, sum(case when abs(n_rating - n_score1) > abs(n_rating - round(n_score2, 0)) then 1 else 0 end) as avg_better
	, count(*)
	- sum(case when abs(n_rating - n_score1) < abs(n_rating - round(n_score2, 0)) then 1 else 0 end)
	- sum(case when abs(n_rating - n_score1) > abs(n_rating - round(n_score2, 0)) then 1 else 0 end) as missing
	, count(*)
from
	train_score_v70
group by
	n_score1

select sum(abs(n_rating - case when n_score1 in (3,4) then n_score1 else round(n_score2,0) end)) from train_score_v70
select sum(abs(n_rating - 
	case when n_score1 in (3,4) then n_score1 
	     when n_score1 in (1,2) then floor(n_score2)
	     when n_score1 in (5) then ceil(n_score2)
	     else round(n_score2,0) end)) from train_score_v70

select sum(abs(n_rating - 
	case when n_score1 in (1,2,3) then floor(n_score2)
	     when n_score1 in (4,5) then ceil(n_score2)
	     else round(n_score2,0) end)) from train_score_v70

select sum(abs(n_rating - 
	case when n_score1 in (1,2,3) then floor(n_score2)
	     when n_score1 in (4,5) then ceil(n_score2)
	     else round(n_score2,0) end)) from train_score_v70a


select sum(abs(n_rating - round(n_score2,0))) from train_score_v70


select floor(3.7), ceil(3.2)

select sum(abs(n_rating - case when n_score1 in (3,4) then n_score1 else n_score2 end)) from train_score_v70