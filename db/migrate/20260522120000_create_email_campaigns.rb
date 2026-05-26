class CreateEmailCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :email_campaigns do |t|
      t.string :subject, null: false
      t.text :recipients, null: false

      t.timestamps
    end
  end
end
