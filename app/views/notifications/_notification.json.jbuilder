json.extract! notification, :id, :whatsapp, :email, :telegram, :created_at, :updated_at
json.url notification_url(notification, format: :json)
