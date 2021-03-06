require "sinatra"
require "json"
require "koala"
require "pry"
require "firebase"
require "./classforms.rb"
require 'omniauth'
require 'omniauth-twitter'
require "mongoid"
require 'twitter'

configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, 'BSuhlPmwPyPpQXVx486tWWnfn', 'fMdOju0tjM9lvovnUidJqwdNxM06QDmW9UCB4VWhHnlRXORZjm'
  end
 
end

client = Twitter::REST::Client.new do |config|
    config.consumer_key    = 'BSuhlPmwPyPpQXVx486tWWnfn'
    config.consumer_secret = 'fMdOju0tjM9lvovnUidJqwdNxM06QDmW9UCB4VWhHnlRXORZjm'
end



helpers do
  # define a current_user method, so we can be sure if an user is
  # authenticated
  def current_user
    !session[:user_id].nil?
  end
end

before do
  # we do not want to redirect to twitter when the path info starts
  # with /auth/
  pass if request.path_info =~ /^\/auth\//
  pass if request.path_info == "/"
  # /auth/twitter is captured by omniauth:
    # when the path info matches /auth/twitter, omniauth will redirect
  # to twitter
  redirect to('/auth/twitter') unless current_user
end



get '/' do
  if not session.has_key?(:user_id) or session[:user_id].nil?
    erb :"login.html"
  else
    redirect "/feed"
  end
end

get '/feed' do
  @courses = get_classes(session[:user_id])
  @client = client
  erb :"feed.html"
end


get '/class/add' do
   erb :"addcourse.html"
end

post '/class/add' do
  user = session[:user_id]
  teacher = params[:teacherhandle].tr('@','')
  classhashtag = params[:coursehashtag].tr('#','')
  course = add_class user, teacher, classhashtag
  
  redirect "/class/add"
end


get '/auth/twitter/callback' do
  session[:user_id] = env['omniauth.auth']['info']['nickname']
  
  # this is the main endpoint to your application
  
  redirect to('/feed')
end

get '/auth/failure' do
  # omniauth redirects to /auth/failure when it encounters a problem
  # so you can implement this as you please

  redirect to('/')
end



post '/class/delete/:id' do
  user = session[:user_id]
  teacher = params[:teacher_handle]
  classhashtag = params[:class_hashtag]
  
  remove_class user, teacher, classhashtag
  redirect "/class"
end




