require 'sinatra'
require 'sinatra/reloader' if development?
# require 'sinatra/base'
require 'pg'
require 'pry' if development?
# require 'net/http'
require 'json'
# require "uri"
require 'httparty'

require_relative 'models/poll'
require_relative 'models/user'
require_relative 'models/choice'
# require_relative 'lib'

enable :sessions

set :bind, '0.0.0.0'
# LIB

def user_exists?(user_email)
  sql = 'select * from users where email = $1'
  response = run_sql(sql,[user_email])
  response.ntuples > 0
end

def poll_taken?(poll_id, user_id)
  sql ="select respondent_ids from polls where poll_id = $1;"
  response = run_sql(sql,[poll_id])
  if response[0]['respondent_ids']
    response[0]['respondent_ids'].split(',').include? (user_id.to_s)
  else
    false
  end
end

def send_email(payload)
  options = { 
    :body => {
      :user_id => ENV['REACT_APP_UID'],
      :service_id => ENV['REACT_APP_SUID'],
      :template_id => ENV['REACT_APP_PCF'],
      :template_params => {
          :name => payload['name'],
          :email => payload['email'],
          :message => payload['message']
      }
    }.to_json,
    :headers => {
      "Content-Type" => "application/json" 
    }
  }
  HTTParty.post('https://api.emailjs.com/api/v1.0/email/send', options)
end
 
 
# POLL AND CHOICES

get "/about" do
erb(:about)
end

get "/" do  #shows all polls on home page
  puts "POLL READ FROM #{request.ip}"
  polls = read_polls()
  erb(:index, locals: {polls: polls})
end

get "/poll/new" do  #form to add new poll
  erb(:new)
end

get "/poll/:poll_id" do  # page to take a poll
  if !session[:user_id]
    redirect "/error?error_code=NOT_LOGGED_IN"
  elsif poll_taken?(params[:poll_id], session[:user_id])
    redirect "/error?error_code=POLL_ALREADY_TAKEN"
  else
    poll = read_poll_by_poll_id(params[:poll_id])
    choices = read_choices_by_poll_id(params[:poll_id])
    erb(:show, locals: {poll: poll, choices: choices})
  end
end


get "/poll/:poll_id/edit" do  # show poll from profile with edit 
  if !!session[:user_id]
    poll = read_poll_by_poll_id(params[:poll_id])
    choices = read_choices_by_poll_id(params[:poll_id])
    erb(:poll_edit, locals: {poll: poll, choices: choices})
    else
    rredirect "/error?error_code=NOT_LOGGED_IN"
  end
end

get "/poll/:poll_id/show" do # poll result
  poll = read_poll_by_poll_id(params[:poll_id])
  choices = read_choices_by_poll_id(params[:poll_id])
  erb(:show_result, locals: {poll: poll, choices: choices})
end


post "/poll" do  # post new poll to DB
  if !!session[:user_id] 
    choices = [params[:choice1], params[:choice2], params[:choice3]]
    create_poll_master(session[:user_id], params[:title], params[:question], choices)
    redirect "/"
    else
    redirect "/error?error_code=NOT_LOGGED_IN"
  end
end

patch "/poll" do # add choices while taking poll
  add_response(session[:user_id], params[:poll_id], params[:choice_id])
  redirect "/"
end

patch "/poll/:poll_id/edit" do # edit poll by creator
  if !!session[:user_id]
    set1 = "#{params[:choice_id1]},#{params[:choice1]}"
    set2 = "#{params[:choice_id2]},#{params[:choice2]}"
    set3 = "#{params[:choice_id3]},#{params[:choice3]}"
    choices = [set1, set2, set3]
    update_poll_master(params[:poll_id], params[:title], params[:question], choices)
    redirect "/user"
    else
    redirect "/error?error_code=NOT_LOGGED_IN"
  end
end

delete "/poll" do
  delete_poll_by_id(params[:poll_id])
  redirect "/user"
end


# USER DETAILS

#TODO: Handle existing users
get "/user" do  #get profile
  if !!session[:user_id]
    user = read_user_by_id(session[:user_id])
    polls = read_polls_by_creator(session[:user_id])
    erb(:user, locals: {user: user, polls: polls })
  end
end

get "/user/new" do #new prfile form -- sign up
  erb(:user_new)
end

get "/user/:user_id/edit" do #filled up form for edit profile
  if !!session[:user_id]
    user = read_user_by_id(session[:user_id])
    erb(:user_edit, locals:{user: user})
  end
end

post "/user" do # new profile submit
  if user_exists?(params[:email])
    redirect "/error?error_code=USER_EXISTS"
    else
    user = create_user(params[:first_name], params[:email], params[:password])[0]
      if user && BCrypt::Password.new(user['password_digested']) == params[:password]
        session[:user_id] = user['user_id']
        redirect "/"
      end
  end
end

patch "/user" do # edit profile submit
  user = read_user_by_id(params[:user_id])
  if user && BCrypt::Password.new(user["password_digested"]) == params[:password]
    update_user(params[:user_id], params[:first_name], params[:email])
    redirect "/user"
    else
      redirect "/error?error_code=INVALID_CREDENTIALS"
  end
end

delete "/user" do #delete profile
  session[:user_id] = nil
  delete_user_by_id(params[:user_id])
  redirect "/"
end


# LOGIN


get "/login" do
  erb(:login)
end

post "/login" do
  user = read_user_by_email( params[:email] )
  if user && BCrypt::Password.new(user["password_digested"]) == params[:password]
    session[:user_id] = user['user_id']
    redirect "/"
    else
    redirect "/error?error_code=INVALID_CREDENTIALS"
  end
end

get "/logout" do
  session[:user_id] = nil
  redirect "/"
end

get "/error" do
  errors = {
    "POLL_ALREADY_TAKEN" => "You have already taken this poll",
    "NOT_LOGGED_IN" => "Please Log In to Continue",
    "USER_EXISTS" => "User already exists",
    "INVALID_CREDENTIALS" => "Invalid Credentials"
  }
  message = errors[params[:error_code]];
  erb(:error, locals:{message: message})
end

post "/email" do
  puts "REACHED FROM #{request.ip}"
  request.body.rewind
  request_payload = JSON.parse request.body.read
  attempts = read_email_attempts(request.ip);
  if attempts <= 0
    response = send_email(request_payload)
    if response.to_str == "OK"
      create_update_email_attempt('create',request.ip, request_payload, 1)
    end
    status 200
  elsif attempts > 0 && attempts < 5
    response = send_email(request_payload)
    if response.to_str == "OK"
      create_update_email_attempt('update',request.ip, request_payload, attempts+1)
    end
    status 200
  else
    status 403
  end
end 