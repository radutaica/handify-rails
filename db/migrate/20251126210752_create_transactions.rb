class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :task, type: :uuid, null: false, foreign_key: true
      t.references :customer, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :tasker, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :platform_fee, precision: 10, scale: 2, null: false
      t.decimal :platform_fee_percentage, precision: 5, scale: 2, null: false
      t.decimal :tasker_amount, precision: 10, scale: 2, null: false
      t.string :stripe_payment_intent_id
      t.string :stripe_transfer_id
      t.string :status, default: 'pending'
      t.string :payment_method, default: 'card'
      t.datetime :paid_at
      t.datetime :released_at
      t.datetime :refunded_at

      t.timestamps
    end
  end
end
