class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :customer_id
      t.string :last_4_digits
      t.references :user

      t.timestamps
    end
    add_index :subscriptions, :user_id
  end
end
