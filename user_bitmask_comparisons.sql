create table user_bitcomps as
select
	a.user_id as user_id1
	, b.user_id as user_id2
	, a.matchstring as matchstring1
	, b.matchstring as matchstring2
	, a.ratestring as ratestring1
	, b.ratestring as ratestring2
	, count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682) & a.ratestring::bit(1682))
	# (a.matchstring::bit(1682) & b.matchstring::bit(1682) & b.ratestring::bit(1682))
	)::text) as non_matches	
	, count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682))
	)::text) as total
	, 
	case when 
		count_bits((
		(a.matchstring::bit(1682) & b.matchstring::bit(1682))
		)::text) = 0 then 0 else
	(
	count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682))
	)::text)
	-count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682) & a.ratestring::bit(1682))
	# (a.matchstring::bit(1682) & b.matchstring::bit(1682) & b.ratestring::bit(1682))
	)::text)
	)
	/  count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682))
	)::text)
	*
	(1-(1/(5^(
	count_bits((
	(a.matchstring::bit(1682) & b.matchstring::bit(1682))
	)::text)
	/4)))) end as score	
from
	user_bitmasks a
	cross join
	user_bitmasks b