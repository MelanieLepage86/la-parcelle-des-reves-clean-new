class ContactMailer < ApplicationMailer
  default to: 'laparcelledesreves.art@gmail.com'

  def new_message(contact_message)
    @contact_message = contact_message
    mail(
      subject: "Nouveau message de #{@contact_message.name}",
      from: 'laparcelle@mg.laparcelledesreves.com'
    )
  end
end

