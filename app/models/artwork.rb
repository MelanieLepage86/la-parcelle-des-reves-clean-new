class Artwork < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  has_many_attached :images

  scope :published, -> { where(published: true) }

  scope :by_sub_category, ->(sub) {
    where("LOWER(sub_category) = ? OR LOWER(sub_category) = ?", sub.downcase, "#{sub.downcase} reproductible")
  }

  enum shipping_category: {
    categorie_1: "categorie_1",
    categorie_2: "categorie_2",
    categorie_3: "categorie_3",
    categorie_4: "categorie_4"
  }

  def reproducible?
    sub_category&.downcase&.include?("reproductible")
  end

  def sold_and_paid?
    return false if reproducible?
    orders.where.not(status: ['pending', 'remboursee']).exists? || sold
  end
end
