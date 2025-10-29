class OrderMailer < ApplicationMailer
  default from: 'laparcelle@sandboxb102747a78724a1bafe1da68162ed7d4.mailgun.org'

  def confirmation_email(order)
    @order = order
    mail(
      to: @order.email,
      reply_to: "laparcelle@sandboxb102747a78724a1bafe1da68162ed7d4.mailgun.org",
      subject: "Confirmation de votre commande ##{@order.id}"
    )
  end
end
