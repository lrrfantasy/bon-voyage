#encoding: utf-8
class User < ActiveRecord::Base
  has_one :personal_action
  has_many :personal_skills

  has_many :user_product_relations
  has_many :products, :through => :user_product_relations
  attr_accessible :user_wechat_id, :level, :name, :sys_stat, :position, :money

  def save_value property, value
    method_name = (property.to_s + '=').to_sym
    self.send method_name, value
    self.save
  end

  def new_user name
    save_value :name, name
    save_value :level, 1
    save_value :position, '成都'
    save_value :money, 500
    clear_sys_stat
  end

  def get_skills
    self.personal_skills
  end

  def learn_skill skill_name
    message = "学习技能失败\n技能不存在或者你已经学会此技能"
    if self.personal_skills.where(:name => skill_name).empty? && !Skill.where(:name => skill_name).empty?
      self.personal_skills.create(:name => skill_name, :level => 1, :exp => 0)
      message = "你成功学会了技能：#{skill_name}"
    end
    clear_sys_stat
    message
  end

  def clear_sys_stat
    save_value :sys_stat, ''
  end

  def at? sys_stat
    self.sys_stat == sys_stat
  end

  def exp_skill skill_name, exp
    skill = self.personal_skills.where(:name => skill_name).first
    skill.receive_exp exp
  end

  def get_stat
    "姓名：#{self.name}\n" +
        "等级：#{self.level.to_s}\n" +
        "位置：#{self.position}\n" +
        "金钱：#{self.money}"
  end

  def go_to city, start_time
    message = ''
    if city == self.position
      message += "你已经在#{city}"
      clear_sys_stat
    elsif City.where(:name => city).empty?
      message += '没有找到该城市'
      clear_sys_stat
    else
      distance = City.where(:name => self.position).first.get_dist city
      cost_time = (distance/100).to_i
      message += "从#{self.position}到#{city}有#{distance}里\n"
      message += "需要用时#{cost_time}秒"

      action = self.personal_action
      action.move_city self.position, city, start_time, cost_time
      save_value :sys_stat, '行动'
    end
    message
  end

  def check_action start_time
    message = ''
    completed = false
    action = self.personal_action
    if action.status == '移动'
      if start_time.to_i >= action.start_time.to_i + action.last_time.to_i
        message += "你已移动到#{action.to}\n"
        save_value :position, action.to
        completed = true
        clear_sys_stat
      else
        remaining_time = action.start_time.to_i + action.last_time.to_i - start_time.to_i
        message += "你正在从#{action.from}到#{action.to}的路上，还要#{remaining_time}秒到达"
      end
    end
    [message, completed]
  end

  def buy_product product_name, amount
    message = ''
    product = Product.where(:name => product_name).first
    product_in_city = City.where(:name => self.position).first.city_product_relations.where(:product_id => product.id).first
    buy_price = product_in_city.base_price
    money_cost = amount.to_i * buy_price
    if product_in_city.base_amount == 0
      message += "市场上没有#{product_name}"
    elsif amount.to_i > product_in_city.base_amount
      message += "市场上#{product_name}不够多"
    elsif self.money < money_cost
      message += "你的钱不够多"
    else
      if self.user_product_relations.where(:product_id => product.id).first.present?
        relation = self.user_product_relations.where(:product_id => product.id).first
        relation.price = (relation.price * relation.amount + product_in_city.base_price * amount.to_i) / (amount.to_i + relation.amount)
        relation.amount += amount.to_i
        relation.save
      else
        self.user_product_relations.create(user_id: self.id, product_id: product.id, amount: amount, price: product_in_city.base_price)
      end
      self.money -= money_cost
      self.save
      message += "你买入了#{product_name}#{amount}个\n支出了金钱#{money_cost}"
    end
    clear_sys_stat
    message
  end

  def sell_product product_name, amount
    message = ''
    product = Product.where(:name => product_name).first
    city = City.where(:name => self.position).first
    sell_price = city.sell_price product
    money_earn = amount.to_i * sell_price

    relation = self.user_product_relations.where(:product_id => product.id).first
    if amount.to_i > relation.amount
      message += "你没有足够的#{product_name}"
    else
      profit = money_earn - relation.price * amount.to_i
      relation.amount -= amount.to_i
      relation.save
      relation.delete if relation.amount == 0
      self.money += money_earn
      self.save
      message += "你售出了#{product_name}#{amount}个\n收入了金钱#{money_earn}\n利润#{profit}"
    end
    clear_sys_stat
    message
  end
end
