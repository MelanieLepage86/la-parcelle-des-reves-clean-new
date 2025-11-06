module NewsletterMailerHelper
  include Rails.application.routes.url_helpers

  def public_image_url(attachment)
    return nil unless attachment.present?
    rails_blob_url(attachment, host: Rails.application.routes.default_url_options[:host], protocol: 'https')
  end
end
