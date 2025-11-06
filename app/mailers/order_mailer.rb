class OrderMailer < ApplicationMailer
  def confirmation_email(order)
    @order = order
    mail(to: @order.email, subject: "Confirmation de votre commande ##{@order.id}")
  end
end
