/* each film gets a concordance from 1-5 
rating = avg concordance * weighting for # of films */
drop function compare_users(numeric, numeric);
CREATE OR REPLACE FUNCTION compare_users(numeric, numeric) RETURNS double precision AS $$
select avg(5-abs(a.n_rating-b.n_rating)) * (1-(1/(5^(count(*)/4)))) 
from
(
select * from flat_train
where user_id = $1 
) a
inner join
(
select * from flat_train
where user_id = $2
) b 
on a.film_id = b.film_id
$$ LANGUAGE sql STABLE STRICT;
