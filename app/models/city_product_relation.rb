class CityProductRelation < ActiveRecord::Base
  belongs_to :city
  belongs_to :product
  attr_accessible :base_amount, :base_price, :city_id, :product_id
end
