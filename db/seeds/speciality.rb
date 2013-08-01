#encoding: utf-8
novice = Profession.where(:name => '见习商人').first
food_merchant = Profession.where(:name => '食品商').first
textile_merchant = Profession.where(:name => '纺织商').first
medicine_merchant = Profession.where(:name => '药品商').first
grocery_merchant = Profession.where(:name => '杂货商').first

accounting = Skill.where(:name => '会计').first
food_trading = Skill.where(:name => '食品贸易').first
animal_trading = Skill.where(:name => '家畜贸易').first
alcohol_trading = Skill.where(:name => '酒类贸易').first
textile_trading = Skill.where(:name => '纺织品贸易').first
medicine_trading = Skill.where(:name => '药材贸易').first
grocery_trading = Skill.where(:name => '杂货贸易').first

novice.specialities.create(skill_id: accounting.id)

food_merchant.specialities.create(skill_id: accounting.id)
food_merchant.specialities.create(skill_id: food_trading.id)
food_merchant.specialities.create(skill_id: animal_trading.id)

textile_merchant.specialities.create(skill_id: accounting.id)
textile_merchant.specialities.create(skill_id: textile_trading.id)

medicine_merchant.specialities.create(skill_id: accounting.id)
medicine_merchant.specialities.create(skill_id: alcohol_trading.id)
medicine_merchant.specialities.create(skill_id: medicine_trading.id)

grocery_merchant.specialities.create(skill_id: accounting.id)
grocery_merchant.specialities.create(skill_id: grocery_trading.id)