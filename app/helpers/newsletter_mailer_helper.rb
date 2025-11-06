module NewsletterMailerHelper
  def public_image_url(image)
    return unless image.attached?

    if Rails.env.production?
      image.service_url
    else
      Rails.application.routes.url_helpers.url_for(image)
    end
  end
end
