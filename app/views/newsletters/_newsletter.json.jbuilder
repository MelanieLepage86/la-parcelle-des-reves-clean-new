json.extract! newsletter, :id, :subject, :body, :created_at, :updated_at
json.url newsletter_url(newsletter, format: :json)
