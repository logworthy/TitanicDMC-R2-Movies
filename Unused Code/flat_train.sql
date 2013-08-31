drop table flat_train;

create table flat_train as
select
	a.*,
	b.*,
	c.n_rating
from
	users a,
	movies b,
	ratings_train c
where
	a.user_id = c.user_id
	and b.film_id = c.film_id;
