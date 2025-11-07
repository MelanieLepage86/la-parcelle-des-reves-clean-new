module NewsletterMailerHelper
  def public_image_url(attachment)
    return nil unless attachment.present? && attachment.blob.present?

    attachment.blob.service_url
  end
end
