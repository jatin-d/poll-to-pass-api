require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg' # to connect to the db
require 'pry' if development?

require_relative 'models/poll'
require_relative 'models/user'
require_relative 'models/choice'
# require_relative 'lib'

enable :sessions


# POLL AND CHOICES

get "/" do  #shows all polls on home page
  polls = read_polls()
  erb(:index, locals: {polls: polls})
end

get "/poll/new" do  #form to add new poll
  erb(:new)
end

get "/poll/:poll_id" do  # page to take a poll
  if !!session[:user_id]
    poll = read_poll_by_poll_id(params[:poll_id])
    choices = read_choices_by_poll_id(params[:poll_id])
    erb(:show, locals: {poll: poll, choices: choices})
  else
    redirect "/login"
  end
end


get "/poll/:poll_id/edit" do  # show poll from profile with edit 
  if !!session[:user_id]  # I dont need it here, but just in case -- delete later
    poll = read_poll_by_poll_id(params[:poll_id])
    choices = read_choices_by_poll_id(params[:poll_id])
    erb(:poll_edit, locals: {poll: poll, choices: choices})
  else
    redirect "/login"
  end
end

get "/poll/:poll_id/show" do # poll result
  poll = read_poll_by_poll_id(params[:poll_id])
  choices = read_choices_by_poll_id(params[:poll_id])
  erb(:show_result, locals: {poll: poll, choices: choices})
end


post "/poll" do  # post new poll to DB
  user = read_user_by_email(params[:email])
  user_id = user['user_id']
  choices = [params[:choice1], params[:choice2], params[:choice3]]
  create_poll_master(user_id, params[:title], params[:question], choices)
  redirect "/"
end

patch "/poll" do # add choices while taking poll
  add_response(1, params[:poll_id], params[:choice_id], params[:response])
  redirect "/"
end

patch "/poll/edit" do # edit poll by creator
  # add_response(1, params[:poll_id], params[:choice_id], params[:response])
  # redirect "/"
end

delete "/poll" do


end


# USER DETAILS


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
  create_user(params[:first_name], params[:email], params[:password])
  redirect "/"
end

patch "/user" do # edit profile submit
  user = read_user_by_id(params[:user_id])
  if user && BCrypt::Password.new(user["password_digested"]) == params[:password]
    update_user(params[:user_id], params[:first_name], params[:email])
    redirect "/user"
  else
    redirect "/user/#{params[:user_id]}/edit"
  end
end

delete "/user" do #delete profile


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
    erb(:login)
  end
  erb(:login)
end

get "/logout" do
  session[:user_id] = nil
  redirect "/"
end