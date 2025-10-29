class ContactsController < ApplicationController
  def new
    @contact_message = ContactMessage.new
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.valid?
      ContactMailer.new_message(@contact_message).deliver_now
      flash[:notice] = "Votre message a bien été envoyé."
      redirect_to new_contact_path
    else
      flash.now[:alert] = "Une erreur est survenue, veuillez réessayer."
      render :new
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:firstname, :name, :email, :message)
  end
end

