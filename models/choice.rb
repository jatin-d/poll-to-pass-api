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

def add_choice(poll_id, choice_id)
    choice = read_choice_by_poll_id_and_choice_id(poll_id, choice_id)
    new_count = choice['counts'].to_i + 1
    sql = "UPDATE choices SET counts = $1 WHERE parent_poll_id = $2 AND choice_id = $3"
    run_sql(sql,[new_count, poll_id, choice_id])
end

def update_respondent(user_id, poll_id)
    sql = "SELECT respondent_ids from polls where poll_id = $1;"
    response = run_sql(sql,[poll_id])
    if response[0]['respondent_ids']
        new_respondent_ids = response[0]['respondent_ids'].concat(",").concat(user_id.to_s)
    else
        new_respondent_ids = user_id
    end
    sql = "UPDATE polls SET respondent_ids = $1 WHERE poll_id = $2"
    run_sql(sql,[new_respondent_ids, poll_id])
end

def add_response(user_id, poll_id, choice_id)
    add_choice(poll_id, choice_id)
    update_respondent(user_id, poll_id)
end

def update_choice(choice_id, choice)
    sql ="UPDATE choices SET choice = $1 WHERE choice_id = $2;"
    run_sql(sql, [choice, choice_id])
end

def delete_choices_by_poll_id(currant_poll_id)
    sql ="DELETE from choices where parent_poll_id = $1"
    run_sql(sql, [currant_poll_id])
end

