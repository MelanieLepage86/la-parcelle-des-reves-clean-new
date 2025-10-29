class ShippingCalculator
  def initialize(order)
    @order = order
  end

  def calculate
    return 0.0 if @order.remise_en_main_propre?

    zone = ShippingZoneResolver.zone_for(@order.country)
    categorized_items = group_items_by_category

    if categorized_items["categorie_4"].to_a.size >= 2
      rate = ShippingRate.find_by!(zone: zone, category: 4)
      return (rate.full_price * categorized_items["categorie_4"].size).round(2)
    end

    highest_cat = categorized_items.keys.max_by { |cat| category_order(cat) }
    total = 0.0

    if highest_cat
      total += full_price_for(zone, highest_cat)
    end

    categorized_items.each do |category, items|
      next if category == highest_cat
      reduced_cost = full_price_for(zone, category) * 0.25
      total += reduced_cost * items.size
    end

    total.round(2)
  end

  private

  def group_items_by_category
    categorized = Hash.new { |h, k| h[k] = [] }
    @order.order_items.includes(:artwork).each do |item|
      category = item.artwork.shipping_category&.to_s
      categorized[category] << item if category.present?
    end
    categorized
  end

  def category_order(category)
    {
      "categorie_1" => 1,
      "categorie_2" => 2,
      "categorie_3" => 3,
      "categorie_4" => 4
    }[category.to_s] || 0
  end

  def full_price_for(zone, category)
    rate = ShippingRate.find_by!(zone: zone, category: category_order(category))
    rate.full_price
  end
end
