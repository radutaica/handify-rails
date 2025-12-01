class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      # Profile preferences
      t.string :preferred_language, default: 'English'
      t.boolean :email_notifications, default: false
      t.boolean :sms_notifications, default: false
      t.boolean :push_notifications, default: true
      t.string :payment_method, default: 'credit_card'
      
      # Arrays stored as JSONB
      t.jsonb :service_categories, default: []
      t.jsonb :preferred_time_windows, default: []
    end
  end
end

