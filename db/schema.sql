CREATE DATABASE poll_to_pass_api;

CREATE TABLE users (
  user_id SERIAL UNIQUE,
  first_name TEXT,
  email TEXT PRIMARY KEY,
  password_digested TEXT
);

CREATE TABLE polls (
  poll_id SERIAL PRIMARY KEY,
  title TEXT,
  question TEXT,
  respondent_ids TEXT,
  creator_id INT REFERENCES users (user_id)
);

CREATE TABLE choices (
  choice_id SERIAL PRIMARY KEY,
  choice TEXT,
  parent_poll_id INT REFERENCES polls (poll_id),
  counts INT DEFAULT 0
);

SELECT * from polls;
SELECT * from polls where creator_id = 1;

UPDATE coices SET counts = '1' WHERE parent_poll_id = '123456789' AND choice_id = ' ';

DROP TABLE users CASCADE;
DROP TABLE polls CASCADE;
DROP TABLE choices CASCADE;