\c postgres;
DROP DATABASE seminar3;
CREATE DATABASE seminar3;
\c seminar3;

CREATE TYPE SKILL AS ENUM ('beginner', 'intermediate', 'advanced');

CREATE TABLE instructor_commission (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 pay_beginner FLOAT(10) NOT NULL,
 pay_intermediate FLOAT(10) NOT NULL,
 pay_advanced FLOAT(10) NOT NULL,
 pay_ensemble FLOAT(10) NOT NULL,
 individual_extra_pay FLOAT(10) NOT NULL
);

ALTER TABLE instructor_commission ADD CONSTRAINT PK_instructor_commission PRIMARY KEY (id);


CREATE TABLE instrument_type (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 type VARCHAR(50) NOT NULL
);

ALTER TABLE instrument_type ADD CONSTRAINT PK_instrument_type PRIMARY KEY (id);


CREATE TABLE person (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 given_name VARCHAR(50) NOT NULL,
 surname VARCHAR(50) NOT NULL,
 personal_number CHAR(12) NOT NULL
);

ALTER TABLE person ADD CONSTRAINT PK_person PRIMARY KEY (id);


CREATE TABLE price_list (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 fee_beginner FLOAT(10) NOT NULL,
 fee_intermediate FLOAT(10) NOT NULL,
 fee_advanced FLOAT(10) NOT NULL,
 fee_ensemble FLOAT(10) NOT NULL,
 individual_extra_cost FLOAT(10) NOT NULL,
 discount FLOAT(10) NOT NULL
);

ALTER TABLE price_list ADD CONSTRAINT PK_price_list PRIMARY KEY (id);


CREATE TABLE rental_instrument (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 brand VARCHAR(100) NOT NULL,
 instrument_type_id INT NOT NULL
);

ALTER TABLE rental_instrument ADD CONSTRAINT PK_rental_instrument PRIMARY KEY (id);


CREATE TABLE skill_level (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 level SKILL NOT NULL,
 instrument_type_id INT NOT NULL
);

ALTER TABLE skill_level ADD CONSTRAINT PK_skill_level PRIMARY KEY (id);


CREATE TABLE timeslot (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 lesson_start TIMESTAMP(6) NOT NULL
);

ALTER TABLE timeslot ADD CONSTRAINT PK_timeslot PRIMARY KEY (id);


CREATE TABLE contact_details (
 person_id INT NOT NULL,
 phone_number VARCHAR(12) NOT NULL,
 email VARCHAR(50) NOT NULL,
 street_address VARCHAR(50) NOT NULL,
 zip_code CHAR(5) NOT NULL
);

ALTER TABLE contact_details ADD CONSTRAINT PK_contact_details PRIMARY KEY (person_id);


CREATE TABLE contact_person (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 relation_to_student VARCHAR(50),
 person_id INT NOT NULL
);

ALTER TABLE contact_person ADD CONSTRAINT PK_contact_person PRIMARY KEY (id);


CREATE TABLE instructor (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT NOT NULL
);

ALTER TABLE instructor ADD CONSTRAINT PK_instructor PRIMARY KEY (id);


CREATE TABLE instructor_instrument_proficiency (
 instructor_id INT NOT NULL,
 instrument_type_id INT NOT NULL
);

ALTER TABLE instructor_instrument_proficiency ADD CONSTRAINT PK_instructor_instrument_proficiency PRIMARY KEY (instructor_id,instrument_type_id);


CREATE TABLE instructor_timeslot (
 instructor_id INT NOT NULL,
 timeslot_id INT NOT NULL
);

ALTER TABLE instructor_timeslot ADD CONSTRAINT PK_instructor_timeslot PRIMARY KEY (instructor_id,timeslot_id);


CREATE TABLE lesson (
 instructor_id INT NOT NULL,
 timeslot_id INT NOT NULL,
 instructor_commission_id INT NOT NULL,
 price_list_id INT NOT NULL,
 level_of_lesson SKILL NOT NULL,
 location CHAR(4) NOT NULL,
 students_max_amount CHAR(10) NOT NULL,
 students_min_amount CHAR(10) NOT NULL
);

ALTER TABLE lesson ADD CONSTRAINT PK_lesson PRIMARY KEY (instructor_id,timeslot_id);


CREATE TABLE student (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 person_id INT NOT NULL,
 contact_person_id INT
);

ALTER TABLE student ADD CONSTRAINT PK_student PRIMARY KEY (id);


CREATE TABLE student_lesson (
 student_id INT NOT NULL,
 instructor_id INT NOT NULL,
 timeslot_id INT NOT NULL,
 instructor_commission_id INT NOT NULL,
 price_list_id INT NOT NULL
);

ALTER TABLE student_lesson ADD CONSTRAINT PK_student_lesson PRIMARY KEY (student_id,instructor_id,timeslot_id,instructor_commission_id,price_list_id);


CREATE TABLE student_skill_level (
 student_id INT NOT NULL,
 skill_level_id INT NOT NULL
);

ALTER TABLE student_skill_level ADD CONSTRAINT PK_student_skill_level PRIMARY KEY (student_id,skill_level_id);


CREATE TABLE ensemble_lesson (
 instructor_id INT NOT NULL,
 timeslot_id INT NOT NULL,
 genre VARCHAR(50) NOT NULL
);

ALTER TABLE ensemble_lesson ADD CONSTRAINT PK_ensemble_lesson PRIMARY KEY (instructor_id,timeslot_id);


CREATE TABLE ensemble_proficiency (
 instructor_id INT NOT NULL,
 genre VARCHAR(50) NOT NULL
);

ALTER TABLE ensemble_proficiency ADD CONSTRAINT PK_ensemble_proficiency PRIMARY KEY (instructor_id,genre);


CREATE TABLE instrument_lesson (
 instructor_id INT NOT NULL,
 timeslot_id INT NOT NULL,
 instrument_type_id INT NOT NULL
);

ALTER TABLE instrument_lesson ADD CONSTRAINT PK_instrument_lesson PRIMARY KEY (instructor_id,timeslot_id);


CREATE TABLE lease_for_instrument (
 id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
 monthly_rental_fee FLOAT(10) NOT NULL,
 rental_start DATE NOT NULL,
 rental_end DATE NOT NULL,
 instrument_delivered DATE,
 instrument_returned DATE,
 instrument_id INT NOT NULL,
 student_id INT NOT NULL
);

ALTER TABLE lease_for_instrument ADD CONSTRAINT PK_lease_for_instrument PRIMARY KEY (id);


CREATE TABLE sibling_relation (
 student_id INT NOT NULL,
 student_sibling_id INT NOT NULL
);

ALTER TABLE sibling_relation ADD CONSTRAINT PK_sibling_relation PRIMARY KEY (student_id,student_sibling_id);


ALTER TABLE rental_instrument ADD CONSTRAINT FK_rental_instrument_0 FOREIGN KEY (instrument_type_id) REFERENCES instrument_type (id);


ALTER TABLE skill_level ADD CONSTRAINT FK_skill_level_0 FOREIGN KEY (instrument_type_id) REFERENCES instrument_type (id);


ALTER TABLE contact_details ADD CONSTRAINT FK_contact_details_0 FOREIGN KEY (person_id) REFERENCES person (id);


ALTER TABLE contact_person ADD CONSTRAINT FK_contact_person_0 FOREIGN KEY (person_id) REFERENCES person (id);


ALTER TABLE instructor ADD CONSTRAINT FK_instructor_0 FOREIGN KEY (person_id) REFERENCES person (id);


ALTER TABLE instructor_instrument_proficiency ADD CONSTRAINT FK_instructor_instrument_proficiency_0 FOREIGN KEY (instructor_id) REFERENCES instructor (id);
ALTER TABLE instructor_instrument_proficiency ADD CONSTRAINT FK_instructor_instrument_proficiency_1 FOREIGN KEY (instrument_type_id) REFERENCES instrument_type (id);


ALTER TABLE instructor_timeslot ADD CONSTRAINT FK_instructor_timeslot_0 FOREIGN KEY (instructor_id) REFERENCES instructor (id) ON DELETE CASCADE;
ALTER TABLE instructor_timeslot ADD CONSTRAINT FK_instructor_timeslot_1 FOREIGN KEY (timeslot_id) REFERENCES timeslot (id) ON DELETE CASCADE;


ALTER TABLE lesson ADD CONSTRAINT FK_lesson_0 FOREIGN KEY (instructor_id) REFERENCES instructor (id);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_1 FOREIGN KEY (timeslot_id) REFERENCES timeslot (id);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_2 FOREIGN KEY (instructor_commission_id) REFERENCES instructor_commission (id);
ALTER TABLE lesson ADD CONSTRAINT FK_lesson_3 FOREIGN KEY (price_list_id) REFERENCES price_list (id);


ALTER TABLE student ADD CONSTRAINT FK_student_0 FOREIGN KEY (person_id) REFERENCES person (id);
ALTER TABLE student ADD CONSTRAINT FK_student_1 FOREIGN KEY (contact_person_id) REFERENCES contact_person (id);


ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_0 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;
ALTER TABLE student_lesson ADD CONSTRAINT FK_student_lesson_1 FOREIGN KEY (instructor_id,timeslot_id) REFERENCES lesson (instructor_id,timeslot_id);


ALTER TABLE student_skill_level ADD CONSTRAINT FK_student_skill_level_0 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;
ALTER TABLE student_skill_level ADD CONSTRAINT FK_student_skill_level_1 FOREIGN KEY (skill_level_id) REFERENCES skill_level (id) ON DELETE CASCADE;


ALTER TABLE ensemble_lesson ADD CONSTRAINT FK_ensemble_lesson_0 FOREIGN KEY (instructor_id,timeslot_id) REFERENCES lesson (instructor_id,timeslot_id);


ALTER TABLE ensemble_proficiency ADD CONSTRAINT FK_ensemble_proficiency_0 FOREIGN KEY (instructor_id) REFERENCES instructor (id) ON DELETE CASCADE;


ALTER TABLE instrument_lesson ADD CONSTRAINT FK_instrument_lesson_0 FOREIGN KEY (instructor_id,timeslot_id) REFERENCES lesson (instructor_id,timeslot_id);
ALTER TABLE instrument_lesson ADD CONSTRAINT FK_instrument_lesson_1 FOREIGN KEY (instrument_type_id) REFERENCES instrument_type (id);


ALTER TABLE lease_for_instrument ADD CONSTRAINT FK_lease_for_instrument_0 FOREIGN KEY (instrument_id) REFERENCES rental_instrument (id);
ALTER TABLE lease_for_instrument ADD CONSTRAINT FK_lease_for_instrument_1 FOREIGN KEY (student_id) REFERENCES student (id);


ALTER TABLE sibling_relation ADD CONSTRAINT FK_sibling_relation_0 FOREIGN KEY (student_id) REFERENCES student (id) ON DELETE CASCADE;
ALTER TABLE sibling_relation ADD CONSTRAINT FK_sibling_relation_1 FOREIGN KEY (student_sibling_id) REFERENCES student (id) ON DELETE CASCADE;


ALTER TABLE person ADD CONSTRAINT unique_personal_number UNIQUE (personal_number);

