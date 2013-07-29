class City < ActiveRecord::Base
  has_many :users
  has_many :city_product_relations
  has_many :products, :through => :city_product_relations
  attr_accessible :latitude, :longitude, :name

  def get_dist(city)
    dest_city = City.where(:name => city).first
    (Math.sqrt((self.latitude - dest_city.latitude)**2 + (self.longitude - dest_city.longitude)**2) * 200).to_i
  end
end
