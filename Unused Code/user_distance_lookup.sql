create table user_distance_lookup as
select
	a.user_id as user_id1,
	b.user_id as user_id2,
	compare_users(a.user_id, b.user_id) as distance
from
	ratings_train a
	cross join
	ratings_train b;
