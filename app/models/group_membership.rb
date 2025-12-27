class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id, message: 'is already a member of this group' }

  def can_leave?
    return false if user == group.admin
    net_balance.zero?
  end

  def net_balance
    BalanceService.new(group).balance_for(user)
  end
end
