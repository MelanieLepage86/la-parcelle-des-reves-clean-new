class ContactMailer < ApplicationMailer
  default to: 'laparcelledesreves.art@gmail.com'

  def new_message(contact)
    @contact = contact
    mail(subject: "Nouveau message de #{@contact.name}", from: 'laparcelle@mg.laparcelledesreves.com')
  end
end
