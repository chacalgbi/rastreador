module ApplicationHelper
  def mobile_device?
    request.user_agent =~ /Mobile|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
  end
end
