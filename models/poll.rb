require 'bcrypt'
require "pg"

def run_sql(sql, params = [])
    conn = PG.connect(ENV['DATABASE_URL'] || {dbname: 'poll_to_pass_api'})
    # conn = PG.connect(dbname: 'poll_to_pass_api')
    record = conn.exec_params(sql, params)
    conn.close
    record
end

def create_poll(poll_title, poll_question, poll_creator_id)
    sql = "INSERT into polls (title, question, creator_id) VALUES ($1, $2, $3) RETURNING *;"
    run_sql(sql, [poll_title, poll_question, poll_creator_id])
end

def read_polls()
    sql = "SELECT * from polls;"
    polls = run_sql(sql,[])
    polls
end

def read_polls_by_creator(creator_id)
    sql = "SELECT * from polls where creator_id =$1;"
    poll = run_sql(sql,[creator_id])
    poll
end

def read_poll_by_poll_id(poll_id)
    sql = "SELECT * from polls where poll_id =$1;"
    poll = run_sql(sql,[poll_id])[0]
    poll
end

def read_poll_by_creator_and_poll(creator_id, poll_id)
    sql = "SELECT * from polls where creator_id = $1 AND poll_id = $2;"
    poll = run_sql(sql, [creator_id, poll_id])[0]
    poll
end

def create_poll_master(user_id, poll_title, question, choices)
    poll = create_poll(poll_title, question, user_id)
    poll_id = poll[0]['poll_id']
    choices.each do |choice|
        create_choice(choice, poll_id)
    end
end

def delete_poll_by_id(poll_id)
    delete_choices_by_poll_id(poll_id)
    sql = "DELETE from polls where poll_id =$1;"
    run_sql(sql,[poll_id])
end

def update_poll(poll_title, poll_question, poll_id)
    sql ="UPDATE polls SET title = $1, question = $2 WHERE poll_id = $3 RETURNING *;"
    run_sql(sql, [poll_title, poll_question, poll_id])
end
# update_poll_master(session[:user_id], params[poll_id], params['title'], params['question'], choices)

def update_poll_master(poll_id, poll_title, question, choices)
    update_poll(poll_title, question, poll_id)
    choices.each do |element|
        splitValues = element.split(',')
        choice_id = splitValues[0]
        choice = splitValues[1]
        update_choice(choice_id, choice)
    end
end

