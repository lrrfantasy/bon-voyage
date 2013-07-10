class User < ActiveRecord::Base
  attr_accessible :user_id, :level, :name, :position
end
