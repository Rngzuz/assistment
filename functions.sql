-- drop all functions
drop function if exists update_elo_ratings;
drop function if exists get_rating;
drop function if exists get_probability;

/**
 * get_probability
 * $1 (int) opponent
 * $2 (int) player
 */
create function get_probability(int, int) returns decimal as $$
    select 1 / ( 1 + 10^( ( $1::decimal - $2::decimal ) / 400 ) )
$$ language sql immutable;

/**
 * get_rating
 * $1 (int) rating (the current rating of the subject)
 * $2 (deicmal) score (1 = win, 0.5 = draw, 0 = loss)
 * $3 (decimal) expected score (calculated with "get_probability")
 */
create function get_rating(int, decimal, decimal) returns int as $$
    select ( $1 + 32 * ( $2 - $3 ) )::int
$$ language sql immutable;

/**
 * update_elo_ratings
 */
create function update_elo_ratings() returns void as $$
declare
    item record;
    old_student_rating int;
    old_problem_rating int;
begin
    for item in select * from assignment order by assignment_id, problem_id asc loop
        old_student_rating := student_rating from student where student_id = item.student_id;
        old_problem_rating := problem_rating from problem where problem_id = item.problem_id;

        update student set student_rating = get_rating(
            old_student_rating,
            item.score,
            get_probability(old_problem_rating, old_student_rating)
        ) where student_id = item.student_id;

        update problem set problem_rating = get_rating(
            old_problem_rating,
            item.score,
            get_probability(old_student_rating, old_problem_rating)
        ) where problem_id = item.problem_id;
    end loop;
end;
$$ language plpgsql;
