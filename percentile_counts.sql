drop table percentile_counts;
create table percentile_counts as 
select user1, percentile, count(distinct user2)
from
(select a.*, (total-non_matches)/(1.0*total) as match_percent from top_user_comparisons a where total > 0 and user1 <> user2) c
cross join
(select (generate_series/100.0) as percentile from generate_series(1,99)) b
where
percentile < match_percent  
group by user1, percentile;
grant all on percentile_counts to anon;
