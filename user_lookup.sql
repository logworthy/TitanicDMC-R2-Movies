drop table user_lookup;
create table user_lookup as
select
	b.user_id as user_id
	, a.user_id as matching_user 
	, a.matchstring
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
	user_bitmasks b
where 
	count_bits((
	a.matchstring::bit(1682) & b.matchstring::bit(1682)
	)::text) > 4 
and 
	a.user_id <> b.user_id
and
	/* (total-non_matches)*1.0/total) > 0.6 */ 
	(
	count_bits((
	a.matchstring::bit(1682) & b.matchstring::bit(1682)
	)::text) 
	-
	count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682) & a.ratestring::bit(1682)) 
	# (a.matchstring::bit(1682) & b.matchstring::bit(1682) & b.ratestring::bit(1682))
	)::text)
	*
	1.0
	)
	/
	count_bits((
	a.matchstring::bit(1682) & b.matchstring::bit(1682)
	)::text) > 0.6;

grant all on user_lookup to anon;
