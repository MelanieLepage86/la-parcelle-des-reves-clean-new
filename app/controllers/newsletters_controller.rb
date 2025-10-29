class NewslettersController < ApplicationController
  before_action :set_newsletter, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @newsletters = Newsletter.all
  end

  def show
  end

  def new
    @newsletter = Newsletter.new
  end

  def edit
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    respond_to do |format|
      if @newsletter.save
        format.html { redirect_to preview_email_newsletter_path(@newsletter), notice: "Newsletter was successfully created."}
        format.json { render :show, status: :created, location: @newsletter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @newsletter.update(newsletter_params)
        format.html { redirect_to @newsletter, notice: "Newsletter was successfully updated." }
        format.json { render :show, status: :ok, location: @newsletter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @newsletter.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @newsletter.destroy!

    respond_to do |format|
      format.html { redirect_to newsletters_path, status: :see_other, notice: "Newsletter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def send_to_subscribers
    @newsletter = Newsletter.find(params[:id])
    subscribers = Subscriber.active

    subscribers.each do |subscriber|
      NewsletterMailer.send_newsletter(subscriber, @newsletter).deliver_later
    end

    flash[:notice] = "Newsletter envoyée !"
    redirect_to admin_dashboard_path
  end

  def preview_email
    @newsletter = Newsletter.find(params[:id])
    @subscriber = Subscriber.new(email: "demo@example.com")

    render template: 'newsletter_mailer/send_newsletter', layout: false
  end

  private

  def set_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:subject, :body, images: [])
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès réservé à l'administration."
    end
  end
end
