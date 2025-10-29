class CreateShippingRates < ActiveRecord::Migration[7.1]
  def change
    create_table :shipping_rates do |t|
      t.string :zone
      t.integer :category
      t.decimal :full_price
      t.decimal :reduced_price

      t.timestamps
    end
  end
end
