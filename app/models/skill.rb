class Skill < ActiveRecord::Base
  has_many :specialities
  has_many :professions, :through => :specialities

  attr_accessible :description, :max_level, :name
end
