-- LESSONS GIVEN QUERY
/* Creates four views where the first selects the filled lesson timeslots for the year in question.
   The following three views each filter this data for the respective kinds of lesson.
   Finally these views are combined into a query presenting the total lessons, and number of each kind
   of lesson given per month.
   */
DROP VIEW lessons_given_year, ensembles, individuals, group_lessons;

-- View filtering existing timeslots to lessons actually given on the year in question
CREATE VIEW lessons_given_year AS
    SELECT timeslot.id AS timeslot_id, timeslot.lesson_start, lesson.students_max_amount
        FROM timeslot INNER JOIN lesson ON timeslot.id = lesson.timeslot_id
        WHERE EXTRACT(year FROM lesson_start) = 2021;                       --change input year here

-- View extracting the ensemble lessons from the given lessons.
CREATE VIEW ensembles AS
    SELECT ensemble_lesson.timeslot_id, lessons_given_year.lesson_start
    FROM lessons_given_year INNER JOIN ensemble_lesson
        ON lessons_given_year.timeslot_id = ensemble_lesson.timeslot_id;

-- View extracting the individual lessons from the given lessons.
CREATE VIEW individuals AS
    SELECT instrument_lesson.timeslot_id, lessons_given_year.lesson_start
    FROM lessons_given_year INNER JOIN instrument_lesson
        ON lessons_given_year.timeslot_id = instrument_lesson.timeslot_id AND lessons_given_year.students_max_amount = 1;

-- View extracting the group lessons from the given lessons.
CREATE VIEW group_lessons AS
    SELECT instrument_lesson.timeslot_id, lessons_given_year.lesson_start
    FROM lessons_given_year INNER JOIN instrument_lesson
        ON lessons_given_year.timeslot_id = instrument_lesson.timeslot_id AND lessons_given_year.students_max_amount > 1;

-- This query combines the respective lesson types and presents them grouped and ordered by the month they were given.
SELECT (EXTRACT(month FROM lessons_given_year.lesson_start)) AS month, COUNT (lessons_given_year.timeslot_id) AS total_lessons,
        COUNT(ensembles.timeslot_id) AS ensembles, COUNT(individuals.timeslot_id) AS individual_lessons,
        COUNT(group_lessons.timeslot_id) AS group_lessons
    FROM lessons_given_year
        LEFT JOIN ensembles ON lessons_given_year.timeslot_id = ensembles.timeslot_id
        LEFT JOIN individuals ON lessons_given_year.timeslot_id = individuals.timeslot_id
        LEFT JOIN group_lessons ON lessons_given_year.timeslot_id = group_lessons.timeslot_id
GROUP BY month ORDER BY month;


-- SIBLING RELATIONS QUERY
/* Counts the number of students with 0, 1 or 2 siblings, using a subquery 'students_sibling_amount' that
   counts the sibling relations of each student*/
SELECT siblings, COUNT(siblings) AS students_with_number_of_siblings
   FROM (SELECT student.id, COUNT(sibling.student_id) AS siblings
            FROM student LEFT OUTER JOIN sibling_relation sibling ON student.id = sibling.student_sibling_id
            GROUP BY student.id)
        AS students_sibling_amount
    GROUP BY siblings ORDER BY siblings;


-- INSTRUCTOR BURNOUT QUERY
/* Lists how many lessons have been given by instructors during the current month, presented in descending
   order by number of lessons, with a specific cutoff point defining which instructors are working to much. */
SELECT *
    FROM (SELECT instructor_id, COUNT(instructor_id) given_lessons
        FROM lesson INNER JOIN timeslot ON lesson.timeslot_id = timeslot.id
        WHERE EXTRACT(MONTH FROM timeslot.lesson_start) = EXTRACT(MONTH FROM CURRENT_DATE)
        GROUP BY instructor_id) AS irregarding_cutoff
    WHERE given_lessons > 5                             -- change cutoff point here
    ORDER BY given_lessons DESC;


-- ENSEMBLE BOOKING QUERY
/* Lists all ensembles held during the coming week, sorted by day of the week and the genre.
   Displays the remaining spots in three different categories according to their number 0, 1-2 or more*/

DROP VIEW lesson_attendees;

--Creates view counting the number of students attending each ensemble
CREATE VIEW lesson_attendees AS
SELECT student_lesson.instructor_id, student_lesson.timeslot_id, COUNT(student_id) students_booked
FROM student_lesson INNER JOIN ensemble_lesson
    ON student_lesson.instructor_id = ensemble_lesson.instructor_id
           AND student_lesson.timeslot_id = ensemble_lesson.timeslot_id
GROUP BY student_lesson.instructor_id, student_lesson.timeslot_id;

--Filters the ensembles according to current week and evaluates places left
SELECT lesson_start::date AS date,  to_char(lesson_start, 'Day') AS weekday,
       to_char((date_bin('15 minutes', lesson_start, TIMESTAMP '2023-01-01')), 'HH24:MI') AS lesson_start,
       ensemble_lesson.genre, CASE
            WHEN lesson.students_max_amount - lesson_attendees.students_booked > 2 THEN 'multiple spots left'
            WHEN lesson.students_max_amount - lesson_attendees.students_booked > 0 THEN 'few spots left'
            ELSE 'fully booked'
            END AS lesson_availability
FROM timeslot
    INNER JOIN lesson ON timeslot.id = lesson.timeslot_id
    INNER JOIN ensemble_lesson ON ensemble_lesson.timeslot_id = lesson.timeslot_id
    INNER JOIN lesson_attendees ON ensemble_lesson.timeslot_id = lesson_attendees.timeslot_id
WHERE EXTRACT(WEEK FROM CURRENT_DATE +1) = EXTRACT(WEEK FROM timeslot.lesson_start)
    AND EXTRACT(YEAR FROM CURRENT_DATE) = EXTRACT(YEAR FROM timeslot.lesson_start)
ORDER BY EXTRACT(ISODOW FROM lesson_start), ensemble_lesson.genre;