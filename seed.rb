require_relative '../models/poll'
require_relative '../models/user'
require_relative '../models/choice'
require "bcrypt"

create_user("Jatin", "jatin@mail", "family")

user = read_user()



# currant_poll = read_poll()
users_poll = read_poll_by_creator(jatin['user_id'])
users_poll_id = users_poll['poll_id']
# currant_poll_creator_id = currant_poll['creator_id']
# currant_poll_by_id_and_Creator = read_poll_by_creator_and_poll(currant_poll_id, currant_poll_creator_id)

create_choice("Sachin", currant_poll_id)
create_choice("Kohli", currant_poll_id)
create_choice("Lara", currant_poll_id)

def create(user_id, poll_title, question, choices)
    poll = create_poll(poll_title, question, user_id)
    poll_id = poll[0]['poll_id']
    choices.each do |choice|
        create_choice(choice, poll_id)
    end
end
  
create(1, "test", "who?", ["1", "2", "3"])








create_poll_master(1, "cricketer", "Who is a better cricketer?", ["Sachin", "Lara", "Bradman"])
create_poll_master(1, "food", "Which is a better dish?", ["pasta", "pizza", "burger"])
create_poll_master(1, "place to visit", "Which is a better place for a day trip?",["Great Ocean Road", "Grampions" "Mount Bullar"])