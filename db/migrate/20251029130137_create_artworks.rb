class CreateArtworks < ActiveRecord::Migration[7.1]
  def change
    create_table :artworks do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :image_url
      t.boolean :published
      t.string :sub_category
      t.string :shipping_category
      t.boolean :sold

      t.timestamps
    end
  end
end
