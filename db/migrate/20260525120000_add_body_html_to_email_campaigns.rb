class AddBodyHtmlToEmailCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :email_campaigns, :body_html, :mediumtext
  end
end
