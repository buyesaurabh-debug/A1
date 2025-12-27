class CreateExpenses < ActiveRecord::Migration[6.1]
  def change
    create_table :expenses do |t|
      t.string :description
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.decimal :tax, precision: 10, scale: 2, default: 0
      t.references :group, null: false, foreign_key: true
      t.references :payer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
