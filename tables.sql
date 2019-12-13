-- drop all tables
drop table if exists assignment;
drop table if exists problem;
drop table if exists student;

/**
 * assistment_data
 */
create table if not exists assistment_data (
    order_id int null,
    assignment_id int null,
    "user_id" int null,
    assistment_id int null,
    problem_id int null,
    original int null,
    correct int null,
    attempt_count int null,
    ms_first_response int null,
    tutor_mode text null,
    answer_type text null,
    sequence_id int null,
    student_class_id int null,
    position int null,
    "type" text null,
    base_sequence_id int null,
    skill_id text null,
    skill_name text null,
    teacher_id int null,
    school_id int null,
    hint_count int null,
    hint_total int null,
    overlap_time int null,
    template_id int null,
    answer_id text null,
    answer_text text null,
    first_action int null,
    bottom_hint text null,
    opportunity int null,
    opportunity_original text null
);

/**
 * student
 */
create table student as select user_id::int student_id, 1000::smallint student_rating from assistment_data group by user_id;

alter table student add primary key (student_id);

/**
 * problem
 */
create table problem as select problem_id::int, 1000::smallint problem_rating from assistment_data group by problem_id;

alter table problem add primary key (problem_id);

/**
 * assignment
 */
create table assignment as select
	assignment_id::int,
	problem_id::int,
	user_id::int as student_id,
	(case when correct = 1 then 1
	 when attempt_count > 1 then 0.5
	 else 0 end)::decimal score
from assistment_data
order by assignment_id, problem_id;

alter table assignment
    add foreign key (student_id) references student (student_id)
        on delete cascade,
    add foreign key (problem_id) references problem (problem_id)
        on delete cascade;
