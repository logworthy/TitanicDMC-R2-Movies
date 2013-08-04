drop table avg_train;
create table avg_train as
with group_avg as
(
select avg(n_rating) as n_score from ratings_train
)
select * from
ratings_train
cross join
group_avg;

drop table user_avg_train;
create table user_avg_train as
with user_avg as
(
select user_id, avg(n_rating) as n_score from ratings_train group by user_id
),
group_avg as
(
select avg(n_rating) as n_score from ratings_train
)
select 
a.user_id, a.n_rating, coalesce(b.n_score, c.n_score) as n_score from
ratings_train a
left join
user_avg b
on a.user_id = b.user_id
cross join 
group_avg c;

drop table film_avg_train;
create table film_avg_train as
with film_avg as
(
select film_id, avg(n_rating) as n_score from ratings_train group by film_id
),
group_avg as
(
select avg(n_rating) as n_score from ratings_train
)
select 
a.user_id, a.n_rating, coalesce(b.n_score, c.n_score) as n_score from
ratings_train a
left join
film_avg b
on a.film_id = b.film_id
cross join 
group_avg c;

drop table user_film_avg_train;
create table user_film_avg_train as
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
a.user_id, a.n_rating, 
case 
when c.n_score is not null and b.n_score is not null then
(b.n_score + c.n_score)/2.0
when c.n_score is not null or b.n_score is not null then
coalesce(b.n_score, c.n_score)
else d.n_score end as n_score
from
ratings_train a
left join
film_avg b
on a.film_id = b.film_id
left join
user_avg c
on a.user_id = c.user_id
cross join 
group_avg d;
