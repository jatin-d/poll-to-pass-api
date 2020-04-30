require_relative "poll"
require 'bcrypt'

def create_choice(creator_choice, currant_poll_id)
    sql = "INSERT into choices (choice, parent_poll_id) VALUES ($1, $2);"
    run_sql(sql, [creator_choice, currant_poll_id])
end

def read_choice()
    sql = "SELECT * from choice"
    choice = run_sql(sql)[0]
    choice
end

def read_choices_by_poll_id(poll_id)
    sql = "SELECT * from choices where parent_poll_id = $1"
    choices = run_sql(sql,[poll_id])
    choices
end

def read_choice_by_poll_id_and_choice_id(poll_id, choice_id)
    sql = "SELECT * from choices where parent_poll_id = $1 AND choice_id = $2"
    choice = run_sql(sql,[poll_id, choice_id])[0]
    choice
end

def add_choice(poll_id, choice_id, response)
    choice = read_choice_by_poll_id_and_choice_id(poll_id, choice_id)
    new_count = "#{choice['counts']},#{response}"
    sql = "UPDATE choices SET counts = $1 WHERE parent_poll_id = $2 AND choice_id = $3"
    run_sql(sql,[new_count, poll_id, choice_id])
end

def update_respondent(user_id, poll_id)
    sql = "UPDATE polls SET respondent_id = $1 WHERE poll_id = $2"
    run_sql(sql,[user_id, poll_id])
end

def add_response(user_id, poll_id, choice_id, response)
    add_choice(poll_id, choice_id, response)
    update_respondent(user_id, poll_id)
end