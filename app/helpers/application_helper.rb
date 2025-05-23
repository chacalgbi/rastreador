module ApplicationHelper
  def status_class(status)
    case status
    when "online"
      "bg-success"
    when "offline"
      "bg-danger"
    else
      ""
    end
  end
end
