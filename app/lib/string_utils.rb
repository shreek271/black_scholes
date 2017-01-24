module StringUtils
  extend self

  def change_maturity_to_years(time_in_days)
    (time_in_days.to_f/365).round(2)
  end

  def change_to_decimal(input_in_number)
    (input_in_number.to_f/100).round(2)
  end

end