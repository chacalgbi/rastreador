class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def view_only_user?
    if Current.user.view_only?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "flash",
            partial: "shared/flash_popup",
            locals: { alert_message: "Você não tem permissão para fazer isso." }
          )
        end
        format.html { redirect_to root_path, alert: "Você não tem permissão para fazer isso." }
      end
    end
  end
end
