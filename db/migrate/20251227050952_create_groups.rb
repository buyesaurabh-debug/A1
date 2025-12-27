class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :admin_id

      t.timestamps
    end
    add_index :groups, :admin_id
  end
end
