class Speciality < ActiveRecord::Base
  belongs_to :skill
  belongs_to :profession
  attr_accessible :profession_id, :skill_id
end
