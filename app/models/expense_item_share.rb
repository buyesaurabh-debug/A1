class ExpenseItemShare < ApplicationRecord
  belongs_to :expense_item
  belongs_to :user

  validates :user_id, uniqueness: { scope: :expense_item_id, message: 'already sharing this item' }
end
