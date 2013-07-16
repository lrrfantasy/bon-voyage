class Product < ActiveRecord::Base
  has_many :city_product_relations
  has_many :cities, :through => :city_product_relations
  attr_accessible :category, :name
end
