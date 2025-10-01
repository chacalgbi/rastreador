module ApplicationHelper
  def mobile_device?
    request.user_agent =~ /Mobile|Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i
  end

  def icon(server)
    case server
    when 'LOCAL'
      'local'
    when 'QA'
      'qa'
    when 'CTE'
      'cte'
    else
      'default'
    end
  end
end
