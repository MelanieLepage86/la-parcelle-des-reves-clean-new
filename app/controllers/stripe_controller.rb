class StripeController < ApplicationController
  before_action :authenticate_user!

  def connect
    return redirect_to portail_artistes_path unless current_user

    unless current_user.stripe_account_id.present?
      account = Stripe::Account.create({
        type: 'express',
        country: 'FR',
        email: current_user.email,
        capabilities: { card_payments: { requested: true }, transfers: { requested: true } }
      })
      current_user.update!(stripe_account_id: account.id)
    else
      account = Stripe::Account.retrieve(current_user.stripe_account_id)
    end

    link = Stripe::AccountLink.create({
      account: account.id,
      refresh_url: connect_stripe_url,
      return_url: root_url,
      type: 'account_onboarding'
    })

    redirect_to link.url, allow_other_host: true
  end

  def dashboard
    if current_user.stripe_account_id.present?
      link = Stripe::Account.create_login_link(current_user.stripe_account_id)
      redirect_to link.url, allow_other_host: true
    else
      redirect_to root_path, alert: "Aucun compte Stripe connecté."
    end
  end
end
