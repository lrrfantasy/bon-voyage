class Profession < ActiveRecord::Base
  has_many :users

  has_many :specialities
  has_many :skills, :through => :specialities
  attr_accessible :fee, :name
end
