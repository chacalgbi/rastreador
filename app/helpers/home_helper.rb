module HomeHelper
  def format_datetime_br(datetime)
    return "" if datetime.blank?
    time_br = Time.parse(datetime).getlocal("-03:00")
    time_br.strftime("%H:%M - %d/%m/%Y")
  end

  def convert_speed(speed)
    return "N/A" if speed.blank?
    km_h = "#{(speed * 1.852).round(0)} km/h"
  end

  def vehicle_icon_svg(category)
    case category.to_s
    when "motorcycle"
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="5" cy="17" r="3"/><circle cx="19" cy="17" r="3"/><path d="M9 17h6"/><path d="M19 17l-2-5h-4l-4-3H5"/><path d="M14 7h3l2 5"/></svg>'
    when "truck"
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 3h15v13H1z"/><path d="M16 8h4l3 5v3h-7V8z"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>'
    when "pickup"
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12h7V6h4l3 3h6v6h2v2h-3"/><path d="M1 12v5h2"/><circle cx="6" cy="17" r="2"/><path d="M8 17h6"/><circle cx="16" cy="17" r="2"/><path d="M18 17h3v-5"/></svg>'
    else
      '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>'
    end.html_safe
  end
end
