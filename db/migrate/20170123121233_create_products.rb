class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.float :stock_price
      t.float :strike_price
      t.float :maturity_time
      t.float :risk_free_rate
      t.float :volatility
      t.timestamps
    end
  end
end
