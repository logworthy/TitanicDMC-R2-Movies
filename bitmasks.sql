/* for a user
- create a bitmask indicating whether they have rated a given film or not 
- create a bitmask indicating whether they rated a film highly or not
*/
drop function user_binmath(integer)
create function user_binmath(integer) returns table (matchstring text, ratestring text)
as
$$
declare
  matchrate integer;
	goodrate integer;
	film integer;
begin
	ratestring = '';
	matchstring = '';
	for film in select film_id from movies
	loop
		matchrate = (select 
		case when (
			select count(*)
			from ratings_train where film_id = film
			and user_id = $1
		) = 1 then case when
			(
			select case when n_rating >= 4 then 1 else 0 end
			from ratings_train where film_id = film
			and user_id = $1
		) = 1 then 2
		else 1 end
		else 0 end);
		if matchrate = 2 then goodrate = 1;
		else goodrate = 0;
		end if;
		matchstring = matchstring||least(matchrate, 1);
		ratestring = ratestring||goodrate;
	end loop;
	return next;
end;
$$ language plpgsql stable strict;

/* count the number of bits in a bitmask */
create function count_bits(text) returns integer
as
$$
select length(replace($1, '0', ''));
$$ language sql immutable strict;

/* function to build bitmasks for each user */
drop function build_bitmasks()
create function build_bitmasks() returns boolean as
$$
declare
	userid integer;
	rowid integer;
begin
	rowid=0;
	for userid in select user_id from users
	loop
		rowid = rowid + 1;
		insert into user_bitmasks 
		(select userid, matchstring, ratestring from user_binmath(userid));
		raise notice 'INSERTED row (%)', rowid;
	end loop;
	return true;
end;
$$ language plpgsql volatile strict;

create table user_bitmasks (
user_id integer
, matchstring text
, ratestring text
)

select build_bitmasks()
