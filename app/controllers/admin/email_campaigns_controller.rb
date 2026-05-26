class Admin::EmailCampaignsController < Admin::BaseController
  def new
    @campaign = EmailCampaign.new
  end

  def create
    @campaign = EmailCampaign.new(campaign_params)

    unless @campaign.valid?
      render :new, status: :unprocessable_entity
      return
    end

    recipients = @campaign.parsed_recipients

    if recipients.empty?
      @campaign.errors.add(:recipients, "nenhum email válido encontrado")
      render :new, status: :unprocessable_entity
      return
    end

    @campaign.save!

    interval_seconds = 30

    recipients.each_with_index do |email, index|
      # Escalona os envios para reduzir pico e evitar bloqueios do provedor SMTP.
      wait_time = (index * interval_seconds).seconds
      CampaignMailer.send_campaign(email, @campaign.id).deliver_later(wait: wait_time)
    end

    redirect_to new_admin_email_campaign_path,
          notice: "#{recipients.size} email(s) enfileirado(s) com intervalos de #{interval_seconds}s para envio."
  end

  private
    def campaign_params
      params.require(:email_campaign).permit(:subject, :recipients, :body_html)
    end
end
