/**
 * get min., max., and avg. student_rating
 */
select min(student_rating) min_rating, max(student_rating) max_rating, avg(student_rating)::int avg_rating from student;

/**
 * get min., max., and avg. problem_rating
 */
select min(problem_rating) min_rating, max(problem_rating) max_rating, avg(problem_rating)::int avg_rating from problem;