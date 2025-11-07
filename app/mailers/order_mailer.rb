class OrderMailer < ApplicationMailer
  def confirmation_email(order)
    @order = order

    attachments.inline['placeholder.jpg'] = File.read(
      Rails.root.join('app/assets/images/placeholder.jpg')
    )

    mail(
      to: @order.email,
      subject: "Confirmation de votre commande ##{@order.id}",
      from: "commande@mg.laparcelledesreves.com"
    )
  end

  def notify_artist(order)
    @order = order
    mail(
      to: "laparcelledesreves.art@gmail.com",
      subject: "🎨 Nouvelle commande sur La Parcelle des Rêves ##{@order.id}",
      from: "notifications@mg.laparcelledesreves.com"
    )
  end
end
