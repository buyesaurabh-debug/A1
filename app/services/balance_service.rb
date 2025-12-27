class BalanceService
  attr_reader :group

  def initialize(group)
    @group = group
  end

  def balance_for(user)
    total_paid_by_user(user) - total_owed_by_user(user) + settlements_paid(user) - settlements_received(user)
  end

  def total_paid_by_user(user)
    group.expenses.where(payer: user).sum(:total_amount).to_f
  end

  def total_owed_by_user(user)
    ExpenseParticipant.joins(:expense)
                      .where(expenses: { group_id: group.id }, user: user)
                      .sum(:share_amount).to_f
  end

  def settlements_paid(user)
    group.settlements.where(from_user: user).sum(:amount).to_f
  end

  def settlements_received(user)
    group.settlements.where(to_user: user).sum(:amount).to_f
  end

  def you_owe(user)
    balance = balance_for(user)
    balance < 0 ? balance.abs : 0
  end

  def owed_to_you(user)
    balance = balance_for(user)
    balance > 0 ? balance : 0
  end

  def balances_between_users
    balances = {}
    group.users.each do |user|
      balances[user.id] = balance_for(user)
    end
    balances
  end

  def debts_for(user)
    debts = []
    group.users.where.not(id: user.id).each do |other_user|
      net = net_balance_between(user, other_user)
      if net < 0
        debts << { user: other_user, amount: net.abs }
      end
    end
    debts
  end

  def credits_for(user)
    credits = []
    group.users.where.not(id: user.id).each do |other_user|
      net = net_balance_between(user, other_user)
      if net > 0
        credits << { user: other_user, amount: net }
      end
    end
    credits
  end

  private

  def net_balance_between(user1, user2)
    paid_by_user1_owed_by_user2 = paid_for_other(user1, user2)
    paid_by_user2_owed_by_user1 = paid_for_other(user2, user1)

    settlements_from_user2_to_user1 = group.settlements.where(from_user: user2, to_user: user1).sum(:amount).to_f
    settlements_from_user1_to_user2 = group.settlements.where(from_user: user1, to_user: user2).sum(:amount).to_f

    (paid_by_user1_owed_by_user2 - paid_by_user2_owed_by_user1) + (settlements_from_user1_to_user2 - settlements_from_user2_to_user1)
  end

  def paid_for_other(payer, participant)
    ExpenseParticipant.joins(:expense)
                      .where(expenses: { group_id: group.id, payer_id: payer.id }, user: participant)
                      .sum(:share_amount).to_f
  end
end
