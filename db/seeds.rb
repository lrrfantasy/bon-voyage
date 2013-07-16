#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Skill.create(name: 'Accounting', max_level: 10, description: 'Bargaining')
City.create([
                {name: '成都', latitude: 30.661079, longitude: 104.063283},
                {name: '长安', latitude: 34.309413, longitude: 108.949270},
                {name: '泉州', latitude: 26.051540, longitude: 119.304829}
            ])
Product.create([
                {name: '蜀锦', category: '纺织品'},
                {name: '大米', category: '食品'},
                {name: '马', category: '畜牲'}
               ])

%w{
  city_product
}.each do |part|
  require File.expand_path(File.dirname(__FILE__))+"/seeds/#{part}.rb"
end