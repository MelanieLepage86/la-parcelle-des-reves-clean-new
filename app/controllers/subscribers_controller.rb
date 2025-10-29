class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(subscriber_params)
    if @subscriber.save
      flash[:notice] = "Merci pour votre inscription !"
      redirect_to new_contact_path
    else
      flash[:alert] = "Une erreur est survenue."
      redirect_to new_contact_path
    end
  end

  def unsubscribe
    @subscriber = Subscriber.find(params[:id])
    @subscriber.update(unsubscribed: true)

    flash[:notice] = "Vous avez été désabonné de la newsletter."
    redirect_to root_path
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
