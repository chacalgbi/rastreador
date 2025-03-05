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
end
