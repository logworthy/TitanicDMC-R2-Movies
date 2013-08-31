drop function score(regclass);
CREATE OR REPLACE FUNCTION score(text, out result numeric) AS 
$func$
begin
execute '(select sum(abs(n_rating-n_score)) from '||$1||')::numeric'
into result;
end
$func$
language plpgsql;
