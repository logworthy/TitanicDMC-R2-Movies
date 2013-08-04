select 'avg_train', sum(abs(n_rating-n_score)) from avg_train
union
select 'user_avg_train', sum(abs(n_rating-n_score)) from user_avg_train
union
select 'film_avg_train', sum(abs(n_rating-n_score)) from film_avg_train
union
select 'user_film_avg_train', sum(abs(n_rating-n_score)) from user_film_avg_train;
