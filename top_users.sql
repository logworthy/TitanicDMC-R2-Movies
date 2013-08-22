/*
select 
user_id,
count_bits(matchstring)
from user_bitmasks
order by count_bits(matchstring) desc
*/

create table top_users as
select * from user_bitmasks
where count_bits(matchstring) >= 150;

/*
select * from top_users
*/

drop table top_user_comparisons;
create table top_user_comparisons as
select
	a.user_id as user1
	, b.user_id as user2
	, count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682) & a.ratestring::bit(1682)) 
	# (a.matchstring::bit(1682) & b.matchstring::bit(1682) & b.ratestring::bit(1682))
	)::text) as non_matches
	, count_bits((
	a.matchstring::bit(1682) & b.matchstring::bit(1682)
	)::text) as total
from
	top_users a
	cross join
	top_users b;

/*
	select a.*, (total-non_matches)/(1.0*total) 
	as match_percent from top_user_comparisons a
	where user1 <> user2 and total > 0
	order by match_percent desc
*/
