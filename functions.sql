-- drop all functions
drop function if exists reset_elo_ratings;
drop function if exists update_elo_ratings;
drop function if exists get_k_factor;
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
 * $2 (int) k factor (the development coefficient)
 * $4 (deicmal) score (1 = win, 0.5 = draw, 0 = loss)
 * $4 (decimal) expected score (calculated with "get_probability")
 */
create function get_rating(int, int, decimal, decimal) returns int as $$
    select ( $1 + $2 * ( $3 - $4 ) )::int
$$ language sql immutable;

/**
 * get_k_factor
 * $1 (int) rating (the subject/player rating)
 *     players below 2100: k-factor of 32 used
 *     players between 2100 and 2400: k-factor of 24 used
 *     players above 2400: k-factor of 16 used.
 */
create function get_k_factor(int) returns int as $$
    select (
        case when $1 < 2100 then
            32
        when $1 between 2100 and 2400 then
            24
        when $1 > 200 then
            16
        end
    )
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
    lock table student in access exclusive mode;
    lock table problem in access exclusive mode;

    for item in select * from assignment order by assignment_id, problem_id asc loop
        old_student_rating := student_rating from student where student_id = item.student_id;
        old_problem_rating := problem_rating from problem where problem_id = item.problem_id;

        update student set student_rating = get_rating(
            old_student_rating,
            get_k_factor(old_student_rating),
            item.score,
            get_probability(old_problem_rating, old_student_rating)
        ) where student_id = item.student_id;

        update problem set problem_rating = get_rating(
            old_problem_rating,
            get_k_factor(old_problem_rating),
            item.score,
            get_probability(old_student_rating, old_problem_rating)
        ) where problem_id = item.problem_id;
    end loop;
end;
$$ language plpgsql;

/**
 * reset_elo_ratings
 */
create function reset_elo_ratings() returns void as $$
begin
    lock table student in access exclusive mode;
    lock table problem in access exclusive mode;

    update student set student_rating = 1000;
    update problem set problem_rating = 1000;
end;
$$ language plpgsql;
