drop table ratings_test;
create table ratings_test (
	user_id numeric,
	film_id numeric
);

copy ratings_test (
	user_id,
	film_id
) from '/home/ubuntu/TitanicDMC-R2-Movies/Ratings_Test.csv'
with delimiter as ',' csv header;

drop table ratings_train;
create table ratings_train (
	user_id numeric,
	film_id numeric,
	n_rating numeric
);

copy ratings_train (
	user_id,
	film_id,
	n_rating
) from '/home/ubuntu/TitanicDMC-R2-Movies/Ratings_Train.csv'
with delimiter as ',' csv header;

drop table users;
create table users (
	user_id numeric,
	age numeric,
	gender text,
	occupation text,
	c_zip text 
);

copy users (
	user_id ,
	age ,
	gender ,
	occupation,
	c_zip 
) from '/home/ubuntu/TitanicDMC-R2-Movies/Users.csv'
with delimiter as ',' csv header;

drop table movies;
create table movies (
	FILM_ID numeric,
	FILM_NAME text,
	FILM_DATE date,
	unknown numeric,
	 Action numeric,
	 Adventure numeric,
	 Animation numeric,
	 "Children's" numeric,
	 Comedy numeric,
	 Crime numeric,
	 Documentary numeric,
	 Drama numeric,
	 Fantasy numeric,
	 "Film-Noir" numeric,
	 Horror numeric,
	 Musical numeric,
	 Mystery numeric,
	 Romance numeric,
	 "Sci-Fi" numeric,
	 Thriller numeric,
	 War numeric,
	 Western numeric 
);

copy movies (
	FILM_ID,
	FILM_NAME,
	FILM_DATE,
	unknown,
	Action,
	Adventure,
	Animation,
	"Children's",
	Comedy,
	Crime,
	Documentary,
	Drama,
	Fantasy,
	"Film-Noir",
	Horror,
	Musical,
	Mystery,
	Romance,
	"Sci-Fi",
	Thriller,
	War,
	Western 
) from '/home/ubuntu/TitanicDMC-R2-Movies/Movies.csv'
with delimiter as ',' csv header;
