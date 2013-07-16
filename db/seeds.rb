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
chengdu = City.where(:name => '成都').first
changan = City.where(:name => '长安').first
quanzhou = City.where(:name => '泉州').first

shu_silk = Product.where(:name => '蜀锦').first
rice = Product.where(:name => '大米').first
horse = Product.where(:name => '马').first

chengdu.city_product_relations.create(product_id: shu_silk.id, base_amount: 20, base_price: 503)
chengdu.city_product_relations.create(product_id: rice.id, base_amount: 43, base_price: 79)
chengdu.city_product_relations.create(product_id: horse.id, base_amount: 0, base_price: 1050)

changan.city_product_relations.create(product_id: shu_silk.id, base_amount: 0, base_price: 754)
changan.city_product_relations.create(product_id: rice.id, base_amount: 0, base_price: 90)
changan.city_product_relations.create(product_id: horse.id, base_amount: 3, base_price: 730)

quanzhou.city_product_relations.create(product_id: shu_silk.id, base_amount: 0, base_price: 807)
quanzhou.city_product_relations.create(product_id: rice.id, base_amount: 60, base_price: 66)
quanzhou.city_product_relations.create(product_id: horse.id, base_amount: 0, base_price: 1030)
