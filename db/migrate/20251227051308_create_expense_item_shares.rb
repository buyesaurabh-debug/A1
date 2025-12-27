class CreateExpenseItemShares < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_item_shares do |t|
      t.references :expense_item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :expense_item_shares, [:expense_item_id, :user_id], unique: true
  end
end
