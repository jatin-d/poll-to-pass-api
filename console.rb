require "pry"
require_relative 'models/poll'
require_relative 'models/user'
require_relative 'models/choice'
require "bcrypt"

def user_exists?(user_email)
    sql = 'select * from users where email = $1'
    response = run_sql(sql,[user_email])
    response.ntuples > 0
end

# def poll_taken?(poll_id, user_id)
#     sql ="select * from polls where poll_id = $1 AND (respondent_ids like '$2,%'::TEXT OR respondent_ids like '%,$2,%'::TEXT OR respondent_ids like '%,$2'::TEXT);"
#     response = run_sql(sql,[poll_id, user_id])
#     response.ntuples > 0
# end
# ASK DT

def poll_taken?(poll_id, user_id)
    sql ="select respondent_ids from polls where poll_id = $1;"
    response = run_sql(sql,[poll_id])
    if response[0]['respondent_ids']
      response[0]['respondent_ids'].split(',').include? (user_id.to_s)
    else
      false
    end
end

binding.pry