class ShippingZoneResolver
  def self.zone_for(country_code)
    country = ISO3166::Country[country_code]

    return "france" if country.alpha2 == "FR"
    return "outre_mer_1" if outre_mer_1.include?(country.alpha2)
    return "outre_mer_2" if outre_mer_2.include?(country.alpha2)
    return "europe" if europe.include?(country.alpha2)
    return "zone_b" if zone_b.include?(country.alpha2)

    "zone_c"
  end

  def self.outre_mer_1
    %w[GP MQ RE GF YT PM MF BL]
  end

  def self.outre_mer_2
    %w[NC PF WF TF]
  end

  def self.europe
    %w[AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE CH GB]
  end

  def self.zone_b
    %w[DZ MA TN NO UA RS RU TR]
  end
end
