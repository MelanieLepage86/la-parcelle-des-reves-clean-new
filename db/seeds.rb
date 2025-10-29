# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_initialize_by(email: 'barbedienne.amelie@gmail.com').tap do |user|
  user.password = 'D@hud131790!!'
  user.password_confirmation = 'D@hud131790!!'
  user.admin = true
  user.avatar_filename = 'Amelie.jpg'
  user.save!
end

User.find_or_initialize_by(email: 'cath.barbedienne@gmail.com').tap do |user|
  user.password = 'Leh@vre17!'
  user.password_confirmation = 'Leh@vre17!'
  user.admin = true
  user.avatar_filename = 'Catherine.jpg'
  user.save!
end

ShippingRate.destroy_all

zones = {
  "france"        => [4.99, 6.99, 7.99, 9.99],
  "outre_mer_1"   => [8.35, 11.25, 14.15, 19.10],
  "outre_mer_2"   => [10.90, 14.50, 20.50, 28.40],
  "europe"        => [14.85, 14.85, 18.45, 20.90],
  "zone_b"        => [22.70, 22.70, 27.10, 29.65],
  "zone_c"        => [33.50, 33.50, 37.30, 51.40]
}

zones.each do |zone, full_prices|
  full_prices.each_with_index do |full_price, index|
    category = index + 1
    reduced_price = (full_price * 0.25).round(2)

    ShippingRate.create!(
      zone: zone,
      category: category,
      full_price: full_price,
      reduced_price: reduced_price
    )
  end
end

puts "✅ Shipping rates seeded!"
