module NewsletterMailerHelper
  include Rails.application.routes.url_helpers

  def public_image_url(attachment)
    return nil unless attachment.present? && attachment.blob.present?

    if Rails.application.config.active_storage.service == :cloudinary
      attachment.service_url
    else
      rails_blob_url(attachment, host: Rails.application.routes.default_url_options[:host], protocol: Rails.application.routes.default_url_options[:protocol])
    end
  end
end
