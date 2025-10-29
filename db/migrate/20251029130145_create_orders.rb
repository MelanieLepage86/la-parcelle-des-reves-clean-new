class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.decimal :total_amount
      t.string :stripe_payment_intent_id
      t.string :status
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address_line
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :delivery_method
      t.decimal :shipping_cost
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
