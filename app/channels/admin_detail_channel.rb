class AdminDetailChannel < ApplicationCable::Channel
  def subscribed
    stream_from "admin_detail_stream"
  end

  def unsubscribed

  end
end
