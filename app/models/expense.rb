class Expense < ApplicationRecord
  belongs_to :group
  belongs_to :payer, class_name: 'User'
  has_many :expense_items, dependent: :destroy
  has_many :expense_participants, dependent: :destroy
  has_many :participants, through: :expense_participants, source: :user

  validates :description, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :tax, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :payer_must_be_group_member

  accepts_nested_attributes_for :expense_items, allow_destroy: true
  accepts_nested_attributes_for :expense_participants, allow_destroy: true

  def items_total
    expense_items.sum(:amount)
  end

  def participants_total
    expense_participants.sum(:share_amount)
  end

  private

  def payer_must_be_group_member
    return unless group && payer
    unless group.member?(payer)
      errors.add(:payer, 'must be a member of the group')
    end
  end
end
