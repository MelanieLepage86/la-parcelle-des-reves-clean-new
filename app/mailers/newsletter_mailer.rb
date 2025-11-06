class NewsletterMailer < ApplicationMailer
  helper :newsletter_mailer

  def send_newsletter(subscriber, newsletter)
    @subscriber = subscriber
    @newsletter = newsletter
    mail(to: @subscriber.email, subject: @newsletter.subject)
  end
end
