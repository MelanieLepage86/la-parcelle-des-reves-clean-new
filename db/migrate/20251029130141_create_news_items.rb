class CreateNewsItems < ActiveRecord::Migration[7.1]
  def change
    create_table :news_items do |t|
      t.string :title
      t.date :date
      t.string :location
      t.text :description
      t.string :source
      t.string :link
      t.string :category

      t.timestamps
    end
  end
end
