-- drop all functions
drop function if exists update_elo_ratings;
drop function if exists get_rating;
drop function if exists get_probability;

/**
 * get_probability
 */
create function get_probability(int, int) returns decimal as $$
    -- $1 = opponent
    -- $2 = player
    select 1 / ( 1 + 10^( ( $1::decimal - $2::decimal ) / 400 ) )
$$ language sql immutable;

/**
 * get_rating
 */
create function get_rating(int, decimal, decimal) returns int as $$
    -- $1 = rating (the current rating of the subject)
    -- $2 = score (1 = win, 0.5 = draw, 0 = loss)
    -- $3 = expected score (calculated with "get_probability")
    select ( $1 + 32 * ( $2 - $3 ) )::int
$$ language sql immutable;

/**
 * update_elo_ratings
 */
create function update_elo_ratings() returns void as $$
declare
    item record;

    s_rating int;
    p_rating int;

    s_result int;
    p_result int;
begin
    for item in select * from assignment order by assignment_id, problem_id asc loop
        s_rating := student_rating from student where student_id = item.student_id;
        p_rating := problem_rating from problem where problem_id = item.problem_id;

        update student set student_rating = get_rating(
            s_rating,
            item.score,
            get_probability(p_rating, s_rating)
        ) where student_id = item.student_id;

        update problem set problem_rating = get_rating(
            p_rating,
            item.score,
            get_probability(s_rating, p_rating)
        ) where problem_id = item.problem_id;
    end loop;
end;
$$ language plpgsql;
