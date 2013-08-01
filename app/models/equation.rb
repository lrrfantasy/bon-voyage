class Equation
  def self.accounting_buy(price, accounting_level)
    (price * (1 - 0.01 * accounting_level)).to_i
  end

  def self.accounting_sell(price, accounting_level)
    (price * (1 + 0.01 * accounting_level)).to_i
  end

  def self.accounting_exp(profit)
    (profit / 1000).to_i + 1
  end

  def self.moving_time(distance)
    (distance / 50).to_i
  end

  def self.trading_amount_per_level(base_price)
    (7000 / (base_price + 300)).to_i
  end

  def self.trading_exp(total_price)
    (total_price / 1000).to_i + 1
  end
end