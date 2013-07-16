#encoding: utf-8
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
