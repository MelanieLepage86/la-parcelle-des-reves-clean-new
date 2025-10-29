class CreateSubscribers < ActiveRecord::Migration[7.1]
  def change
    create_table :subscribers do |t|
      t.string :email
      t.boolean :confirmed
      t.boolean :unsubscribed

      t.timestamps
    end
  end
end
