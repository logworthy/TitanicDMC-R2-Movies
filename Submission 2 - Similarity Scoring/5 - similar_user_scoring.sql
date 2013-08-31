
/* Edited to only score the test set for clarity/brevity */

/*  1.  Create the averages table as a fallback for when we don't find similar users */
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

/*  2.  Add a rating based on the most similar top user where available*/
	drop table test_score;
	create table test_score as
	select a.*
		, rate_film(a.user_id, a.film_id) as n_score1
		, b.n_score as n_score2
	from 
		ratings_test a
		, user_film_avg_test b
	where
		a.user_id = b.user_id
		and a.film_id = b.film_id;


/*  3.  Apply a rule to decide how to combine the two types of score 
		most effectively.

	    Scoring on the training data suggested that for ratings where
	    the similar user had a high rating we should round the average
	    with 'ceil' and when the user had a low rating we should round
	    the average with 'floor'.

	    This reduced training set error significantly, but appears to
	    be overfitting...  */
drop table test_score_final;
create table test_score_final as
select 
	user_id
	, film_id
	, case 
	     when n_score1 in (1,2,3) then floor(n_score2)
	     when n_score1 in (4,5) then ceil(n_score2)
	     else round(n_score2,0) 
	end as n_rating
from test_score
order by 
	user_id
	, film_id

copy test_score_final
to '/home/anon/TitanicDMC-R2-Movies/Submission 2 - Similarity Scoring/Ratings_Test.csv'
CSV HEADER;
