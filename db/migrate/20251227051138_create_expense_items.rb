class CreateExpenseItems < ActiveRecord::Migration[6.1]
  def change
    create_table :expense_items do |t|
      t.string :name
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.references :expense, null: false, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.boolean :shared, default: false

      t.timestamps
    end
  end
end
