#encoding: utf-8
class User < ActiveRecord::Base
  has_one :personal_action
  belongs_to :city
  belongs_to :profession
  has_many :personal_skills

  has_many :user_product_relations
  has_many :products, :through => :user_product_relations

  has_many :purchasings
  has_many :products, :through => :purchasings
  attr_accessible :user_wechat_id, :level, :name, :sys_stat, :money, :load

  def save_value(property, value)
    method_name = (property.to_s + '=').to_sym
    self.send method_name, value
    self.save
  end

  def new_user(name)
    save_value :name, name
    save_value :level, 1
    save_value :money, 20000
    save_value :load, 100
    save_value :city, City.where(:name => '成都').first
    save_value :profession, Profession.where(:name => '见习商人').first
    clear_sys_stat
  end

  def learn_skill(skill_name)
    if Skill.where(:name => skill_name).empty?
      message = '技能不存在'
    elsif !self.personal_skills.where(:name => skill_name).empty?
      message = '你已经学会该技能'
    elsif self.profession.skills.where(:name => skill_name).empty?
      message = '你不能学习该技能'
    else
      self.personal_skills.create(:name => skill_name, :level => 1, :exp => 0)
      message = "你成功学会了技能：#{skill_name}"
    end
    clear_sys_stat
    message
  end

  def intro_skill(skill_name)
    message = '技能不存在'
    clear_sys_stat
    unless Skill.where(:name => skill_name).empty?
      skill = Skill.where(:name => skill_name).first
      message = "#{skill.name}\n#{skill.description}\n直接回复技能名学习"
      save_value :sys_stat, SysStat.learn_skill
    end
    message
  end

  def clear_sys_stat
    save_value :sys_stat, ''
  end

  def at?(sys_stat)
    self.sys_stat == sys_stat
  end

  def exp_skill(skill_name, exp)
    skill = self.personal_skills.where(:name => skill_name).first
    skill.nil? ? '' : skill.receive_exp(exp)
  end

  def get_stat
    "姓名：#{self.name}\n" +
        "等级：#{self.level.to_s}\n" +
        "职业：#{self.profession.name}\n" +
        "位置：#{self.city.name}\n" +
        "金钱：#{self.money}\n" +
        "装载：#{current_load}/#{self.load}"
  end

  def go_to(city, start_time)
    message = ''
    if city == self.city.name
      message += "你已经在#{city}"
      clear_sys_stat
    elsif City.where(:name => city).empty?
      message += '没有找到该城市'
      clear_sys_stat
    else
      distance = self.city.get_dist city
      cost_time = Equation.moving_time distance
      message += "从#{self.city.name}到#{city}有#{distance}里\n"
      message += "需要用时#{cost_time}秒"

      action = self.personal_action
      action.move_city self.city.name, city, start_time, cost_time
      save_value :sys_stat, SysStat.action
    end
    message
  end

  def check_action(current_time)
    message = ''
    completed = false
    action = self.personal_action
    if action.status == '移动'
      if current_time.to_i >= action.start_time.to_i + action.last_time
        message += "你已移动到#{action.to}\n"
        save_value :city, City.where(:name => action.to).first
        completed = true
        self.purchasings.each { |purchasing| purchasing.delete }
        clear_sys_stat
      else
        remaining_time = action.start_time.to_i + action.last_time - current_time.to_i
        message += "你正在从#{action.from}到#{action.to}的路上，还要#{remaining_time}秒到达"
      end
    end
    [message, completed]
  end

  def buy_product(product_name, amount)
    message = ''
    product = Product.where(:name => product_name).first
    return '' if product.nil?

    product_in_city = self.city.city_product_relations.where(:product_id => product.id).first
    buy_price = accounted_buy_price product_in_city.base_price
    money_cost = amount.to_i * buy_price
    available_amount = product_available_amount product, product_in_city
    current_load = current_load()
    if product_in_city.base_amount == 0
      message += "市场上没有#{product_name}\n"
    elsif amount.to_i > available_amount
      message += "市场上没有足够的#{product_name}\n"
    elsif self.money < money_cost
      message += "你的钱不够多\n"
    elsif amount.to_i > (self.load - current_load)
      message += "你的货仓不够\n"
    else
      purchase product, amount, buy_price
      self.money -= money_cost
      self.save
      message += "你买入了#{product_name}#{amount}个\n支出了金钱#{money_cost}\n"
      message += exp_skill("#{product.category}买卖", Equation.trading_exp(money_cost))
    end
    message += "*********\n#{buy_market_info}"
    message
  end

  def sell_product(product_name, amount)
    message = ''
    product = Product.where(:name => product_name).first
    return '' if product.nil?
    money_earn = amount.to_i * self.accounted_sell_price(product)

    relation = self.user_product_relations.where(:product_id => product.id).first
    if amount.to_i > relation.amount
      message += "你没有足够的#{product_name}\n"
    else
      profit = money_earn - relation.price * amount.to_i
      relation.amount -= amount.to_i
      relation.save
      relation.delete if relation.amount == 0
      self.money += money_earn
      self.save
      message += "你售出了#{product_name}#{amount}个\n收入了金钱#{money_earn}\n利润#{profit}\n"
      message += self.exp_skill("会计", Equation.accounting_exp(profit)) if profit > 0
    end
    message += "*********\n#{sell_market_info}"
    message
  end

  def sell_all
    message = ''
    money_earn = 0
    profit = 0
    self.user_product_relations.each { |relation|
      money_earn += relation.amount * self.accounted_sell_price(relation.product)
      profit += relation.amount * (self.accounted_sell_price(relation.product) - relation.price)
      relation.delete
    }
    self.money += money_earn
    self.save
    message += "你售出了全部货物\n收入了金钱#{money_earn}\n利润#{profit}\n"
    message += self.exp_skill("会计", (profit / 100).to_i) if profit > 0
    message
  end

  def product_available_amount(product, city_product_relation)
    purchasing = self.purchasings.where(:product_id => product.id).first
    trade_skill = self.personal_skills.where(:name => "#{product.category}买卖").first
    skill_level = trade_skill.nil? ? 0 : trade_skill.level
    increased_amount = skill_level * Equation.trading_amount_per_level(city_product_relation.base_price)
    city_product_relation.base_amount + increased_amount - (purchasing.nil? ? 0 : purchasing.amount)
  end

  def buy_market_info
    current_load = current_load()

    message = "持有金钱：#{self.money}\n"
    message += "装载：#{current_load}/#{self.load}\n"
    message += "市场里的商品：\n"
    all_products = self.city.city_product_relations
    all_products.all.reject { |relation|
      relation.base_amount == 0
    }.each { |relation|
      product = Product.where(:id => relation.product_id).first
      available_amount = self.product_available_amount product, relation
      buy_price = accounted_buy_price relation.base_price
      buyable_amount = (self.money / buy_price).to_i
      buyable_amount = available_amount if buyable_amount > available_amount
      buyable_amount = self.load - current_load if buyable_amount > (self.load - current_load)
      message += "#{product.name} #{product.category} 数量：#{available_amount} 价格：#{buy_price} 可买：#{buyable_amount}\n"
    }
    save_value :sys_stat, SysStat.buy
    message
  end

  def sell_market_info
    message = "你所拥有的商品：\n"

    self.user_product_relations.all.each { |relation|
      product = Product.where(:id => relation.product_id).first
      sell_price = self.accounted_sell_price product
      message += "#{product.name} #{product.category} 数量：#{relation.amount} 买入价：#{relation.price} 卖出价：#{sell_price}\n"
    }
    save_value :sys_stat, SysStat.sell
    message
  end

  def accounted_sell_price product
    product_in_city = self.city.city_product_relations.where(:product_id => product.id).first
    price = product_in_city.base_price
    price = (price / 2).to_i if (product_in_city.base_amount > 0)
    accounting_level = self.personal_skills.where(:name => '会计').empty? ? 0 : self.personal_skills.where(:name => '会计').first.level
    Equation.accounting_sell(price, accounting_level)
  end

  def change_profession(profession_name)
    profession = Profession.where(:name => profession_name).first
    message = '没有该职业'
    if profession.present?
      if self.money < profession.fee
        message = '你的钱不够成为该职业'
      else
        save_value :profession, profession
        self.money -= profession.fee
        self.save
        message = "支出#{profession.fee}\n你已成为#{profession.name}"
      end
    end
    message
  end

  def is_gm?
    self.user_wechat_id == 'client'
  end

  def add_load
    money_cost = self.load**2
    message = ''
    if self.money < money_cost
      message += '你的钱不够'
    else
      self.money -= money_cost
      self.load += 100
      self.save
      message += "花费#{money_cost}，装载增加了100"
    end
    message
  end

  private

  def purchase(product, amount, buy_price)
    if (relation = self.user_product_relations.where(:product_id => product.id).first).present?
      relation.price = (relation.price * relation.amount + buy_price * amount.to_i) / (amount.to_i + relation.amount)
      relation.amount += amount.to_i
      relation.save
    else
      self.user_product_relations.create(user_id: self.id, product_id: product.id, amount: amount, price: buy_price)
    end

    if (purchasing = self.purchasings.where(:product_id => product.id).first).present?
      purchasing.amount += amount.to_i
      purchasing.save
    else
      self.purchasings.create(user_id: self.id, product_id: product.id, amount: amount.to_i)
    end
  end

  def accounted_buy_price base_price
    accounting_level = self.personal_skills.where(:name => '会计').empty? ? 0 : self.personal_skills.where(:name => '会计').first.level
    Equation.accounting_buy(base_price, accounting_level)
  end

  def current_load
    current_load = 0
    self.user_product_relations.all.each { |relation|
      current_load += relation.amount
    }
    current_load
  end
end
