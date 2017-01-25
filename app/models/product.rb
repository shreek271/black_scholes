class Product < ApplicationRecord
  include Math
  # used for finding implied vol based on a market (target) price
  LOW_VOL, HIGH_VOL, VOL_TOLERANCE = 0.0, 5.0, 0.0001

  # used for min/max normal distribution
  MIN_Z_SCORE, MAX_Z_SCORE = -8.0, +8.0
  validates :name, presence: true
  validates_numericality_of :volatility, presence: true, less_than_or_equal_to: 100, greater_than_or_equal_to: 0
  validates_numericality_of :risk_free_rate, presence: true , less_than_or_equal_to: 100, greater_than_or_equal_to: 0
  validates :stock_price, presence: true
  validates :strike_price, presence: true
  validates_numericality_of :maturity_time, presence: true, greater_than: 0
  
  attr_accessor :s_id, :sensitive_factor

  def price_call( underlying, strike, time, interest, sigma, dividend )
    d1 = d_one( underlying, strike, time, interest, sigma, dividend )
    discounted_underlying = exp(-1.0 * dividend * time) * underlying
    probability_weighted_value_of_being_exercised = discounted_underlying * norm_sdist( d1 )
					
    d2 = d1 - ( sigma * sqrt(time) )
    discounted_strike = exp(-1.0 * interest * time) * strike
    probability_weighted_value_of_discounted_strike = discounted_strike * norm_sdist( d2 )
	
    expected_value = (probability_weighted_value_of_being_exercised - probability_weighted_value_of_discounted_strike).round(2)
  end


  def price_put( underlying, strike, time, interest, sigma, dividend )
    d2 = d_two( underlying, strike, time, interest, sigma, dividend )
    discounted_strike = strike * exp(-1.0 * interest * time)
    probabiltity_weighted_value_of_discounted_strike = discounted_strike * norm_sdist( -1.0 * d2 )
	
    d1 = d2 + ( sigma * sqrt(time) )
    discounted_underlying = underlying * exp(-1.0 * dividend * time)
    probability_weighted_value_of_being_exercised = discounted_underlying * norm_sdist( -1.0 * d1 )
	
    expected_value = (probabiltity_weighted_value_of_discounted_strike - probability_weighted_value_of_being_exercised).round(2)
  end

  def d_one( underlying, strike, time, interest, sigma, dividend )
    numerator = ( log(underlying / strike) + (interest - dividend + 0.5 * sigma ** 2.0 ) * time)
    denominator = ( sigma * sqrt(time) )
    numerator / denominator
  end
	
  def d_two( underlying, strike, time, interest, sigma, dividend ) 
    d_one( underlying, strike, time, interest, sigma, dividend ) - ( sigma * sqrt(time) )
  end

  # Normal Standard Distribution
  # using Taylor's approximation
  def norm_sdist( z )
    return 0.0 if z < MIN_Z_SCORE
    return 1.0 if z > MAX_Z_SCORE	
    i, sum, term = 3.0, 0.0, z	
    while( sum + term != sum )
      sum = sum + term
      term = term * z * z / i
	  i += 2.0
    end	
    0.5 + sum * phi(z)
  end
	
  # Standard Gaussian pdf
  def phi(x)
    numerator = exp(-1.0 * x*x / 2.0)
    denominator = sqrt(2.0 * PI)
    numerator / denominator
  end
  
end
