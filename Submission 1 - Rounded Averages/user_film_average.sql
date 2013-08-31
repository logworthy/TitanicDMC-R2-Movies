/** 1.  Score the training set **/

	drop table user_film_avg_train;
	create table user_film_avg_train as

	/* pre-calculate film, user and overall averages */
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

	/* if user and film averages exist, combine them
	otherwise take whichever exists
	otherwise take the overall average */
	select 
	a.user_id, a.film_id, a.n_rating, 
	round(
		case 
			when c.n_score is not null and b.n_score is not null 
				then (b.n_score + c.n_score)/2.0
			when c.n_score is not null or b.n_score is not null 
				then coalesce(b.n_score, c.n_score)
			else 
				d.n_score 
		end
		, 0
	) as n_score
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

/** 2.  Score the test set **/
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
		round(
			case 
				when c.n_score is not null and b.n_score is not null 
					then (b.n_score + c.n_score)/2.0
				when c.n_score is not null or b.n_score is not null 
					then coalesce(b.n_score, c.n_score)
				else 
					d.n_score 
			end
			, 0
		) as n_rating
	from
		ratings_test a
	left join
		film_avg b
	on 
		a.film_id = b.film_id
	left join
		user_avg c
	on 
		a.user_id = c.user_id
	cross join
		group_avg d
	order by
		a.user_id
		, a.film_id;

/** 3.  Export to CSV **/
	copy user_film_avg_test
	to '/home/anon/TitanicDMC-R2-Movies/Submission 1 - Rounded Averages/Ratings_Test.csv'
	CSV HEADER;