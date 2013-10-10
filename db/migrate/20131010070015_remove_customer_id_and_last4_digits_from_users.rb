class RemoveCustomerIdAndLast4DigitsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :customer_id
    remove_column :users, :last_4_digits
  end

  def down
    add_column :users, :last_4_digits, :string
    add_column :users, :customer_id, :string
  end
end
