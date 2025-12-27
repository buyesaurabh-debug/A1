class ExpenseParticipant < ApplicationRecord
  belongs_to :expense
  belongs_to :user

  validates :share_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :expense_id, message: 'already participates in this expense' }
  validate :user_must_be_group_member

  private

  def user_must_be_group_member
    return unless expense&.group && user
    unless expense.group.member?(user)
      errors.add(:user, 'must be a member of the group')
    end
  end
end
