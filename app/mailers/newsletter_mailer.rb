class NewsletterMailer < ApplicationMailer
  default from: 'laparcelle@sandboxb102747a78724a1bafe1da68162ed7d4.mailgun.org'

  def send_newsletter(subscriber, newsletter)
    @newsletter = newsletter
    @subscriber = subscriber
    mail(
      to: @subscriber.email,
      reply_to: 'laparcelle@sandboxb102747a78724a1bafe1da68162ed7d4.mailgun.org',
      subject: newsletter.subject
    )
  end
end
