CREATE DATABASE poll_to_pass_api;

CREATE TABLE polls (
  poll_id SERIAL PRIMARY KEY,
  title TEXT,
  question TEXT,
  respondent_id TEXT,
  creator_id INT
);


CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  first_name TEXT,
  email TEXT,
  password_digested TEXT
);

CREATE TABLE choices (
  choice_id SERIAL PRIMARY KEY,
  choice TEXT,
  parent_poll_id TEXT
);

ALTER TABLE choices ADD COLUMN counts TEXT;

SELECT * from polls;
SELECT * from polls where creator_id = 1;

UPDATE coices SET counts = '1' WHERE parent_poll_id = '123456789' AND choice_id = ' ';
