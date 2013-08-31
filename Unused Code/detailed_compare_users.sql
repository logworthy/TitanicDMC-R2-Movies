select a.n_rating, b.n_rating
from
(
select * from flat_train
where user_id = 324
) a
inner join
(
select * from flat_train
where user_id = 427 
) b 
on a.film_id = b.film_id;

select a.n_rating, b.n_rating
from
(
select * from flat_train
where user_id = 324
) a
inner join
(
select * from flat_train
where user_id = 570 
) b 
on a.film_id = b.film_id;
