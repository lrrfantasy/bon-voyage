class Equation
  def self.accounting_buy(price, accounting_level)
    (price * (1 - 0.01 * accounting_level)).to_i
  end

  def self.accounting_sell(price, accounting_level)
    (price * (1 + 0.01 * accounting_level)).to_i
  end

  def self.accounting_exp(profit)
    (profit / 100).to_i
  end

  def self.moving_time(distance)
    (distance / 50).to_i
  end
end