class NewsletterMailer < ApplicationMailer
  def send_newsletter(subscriber, newsletter)
    @subscriber = subscriber
    @newsletter = newsletter
    mail(to: @subscriber.email, subject: @newsletter.title)
  end
end
