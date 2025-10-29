class Artwork < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  has_many_attached :images

  scope :published, -> { where(published: true) }
  scope :by_sub_category, ->(sub) { where(sub_category: sub) }

  enum shipping_category: {
    categorie_1: "categorie_1",
    categorie_2: "categorie_2",
    categorie_3: "categorie_3",
    categorie_4: "categorie_4"
  }

  def sold_and_paid?
    orders.where.not(status: ['pending', 'remboursee']).exists?
  end
end
