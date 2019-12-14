/**
 * get min., max., and avg. student_rating
 */
select min(student_rating) min_rating, max(student_rating) max_rating, avg(student_rating)::int avg_rating from student;

/**
 * get min., max., and avg. problem_rating
 */
select min(problem_rating) min_rating, max(problem_rating) max_rating, avg(problem_rating)::int avg_rating from problem;

/**
 * get assignment_rating based on the avg. of problem_rating
 */
select assignment_id, avg(problem_rating) assignment_rating from assignment join problem using (problem_id) group by assignment_id;

/**
 * get min., max., and avg. assignment_rating
 */
select min(assignment_rating) min_rating, max(assignment_rating) max_rating, avg(assignment_rating)::int avg_rating from (select avg(problem_rating)::int assignment_rating from assignment join problem using (problem_id) group by assignment_id) assignment_aggregate;
