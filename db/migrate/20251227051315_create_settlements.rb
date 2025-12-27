class CreateSettlements < ActiveRecord::Migration[6.1]
  def change
    create_table :settlements do |t|
      t.references :from_user, null: false, foreign_key: { to_table: :users }
      t.references :to_user, null: false, foreign_key: { to_table: :users }
      t.references :group, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :note

      t.timestamps
    end
  end
end
