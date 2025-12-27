class ExpenseItem < ApplicationRecord
  belongs_to :expense
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :expense_item_shares, dependent: :destroy
  has_many :shared_users, through: :expense_item_shares, source: :user

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :must_be_assigned_or_shared

  def split_amount
    return amount if assigned_to.present?
    return 0 if shared_users.empty?
    (amount / shared_users.count).round(2)
  end

  private

  def must_be_assigned_or_shared
    if assigned_to.blank? && !shared
      errors.add(:base, 'Item must be assigned to a user or marked as shared')
    end
  end
end
