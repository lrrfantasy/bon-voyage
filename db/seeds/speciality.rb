#encoding: utf-8

novice = Profession.where(:name => '见习商人').first

accounting = Skill.where(:name => '会计').first

novice.specialities.create(skill_id: accounting.id)