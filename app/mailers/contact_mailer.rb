class ContactMailer < ApplicationMailer
  default from: 'no-reply@laparcelledesreves.com', to: 'laparcelledesreves.art@gmail.com'

  def new_message(contact_message)
    @contact_message = contact_message
    mail(
      reply_to: @contact_message.email,
      subject: "Nouveau message de #{@contact_message.firstname} #{@contact_message.name}"
    )
  end
end
