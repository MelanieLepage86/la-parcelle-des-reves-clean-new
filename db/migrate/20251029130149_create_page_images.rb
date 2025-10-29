class CreatePageImages < ActiveRecord::Migration[7.1]
  def change
    create_table :page_images do |t|
      t.string :name

      t.timestamps
    end
  end
end
