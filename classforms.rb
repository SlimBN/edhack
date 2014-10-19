require 'mongoid'

Mongoid.load!("mongoid.yml")

class User
  include Mongoid::Document
  field :userid
  
  embeds_many :courses
end

class Course
  include Mongoid::Document
  field :teacher
  field :hashtag

  embedded_in :user
end


def user_exists?(id)
  User.where(userid: id).exists?
end

def add_class(user_id, teacher_handle, class_hashtag) 
  if user_exists?(user_id)
    user = User.find(userid: user_id)
  else
    user = User.new(userid: user_id)
    
  end

  course = user.courses.new(hashtag: class_hashtag, teacher: teacher_handle)

  
end


