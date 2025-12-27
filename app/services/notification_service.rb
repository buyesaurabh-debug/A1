class NotificationService
  class << self
    def notify_expense_created(expense)
      group = expense.group
      payer = expense.payer

      expense.expense_participants.includes(:user).each do |participant|
        next if participant.user == payer

        NotificationsChannel.broadcast_to_user(participant.user, {
          type: 'info',
          title: 'New Expense',
          message: "#{payer.display_name} added expense '#{expense.description}' (#{ActionController::Base.helpers.number_to_currency(expense.total_amount)}) in #{group.name}",
          expense_id: expense.id,
          group_id: group.id
        })
      end

      GroupChannel.broadcast_to_group(group, {
        type: 'info',
        title: 'New Expense',
        message: "#{payer.display_name} added '#{expense.description}'",
        reload: false
      })
    end

    def notify_settlement_created(settlement)
      group = settlement.group
      from_user = settlement.from_user
      to_user = settlement.to_user

      NotificationsChannel.broadcast_to_user(to_user, {
        type: 'success',
        title: 'Settlement Received',
        message: "#{from_user.display_name} settled #{ActionController::Base.helpers.number_to_currency(settlement.amount)} with you in #{group.name}",
        settlement_id: settlement.id,
        group_id: group.id
      })

      GroupChannel.broadcast_to_group(group, {
        type: 'success',
        title: 'Settlement',
        message: "#{from_user.display_name} settled with #{to_user.display_name}",
        reload: false
      })
    end

    def notify_member_added(group, member, added_by)
      group.users.where.not(id: member.id).each do |user|
        NotificationsChannel.broadcast_to_user(user, {
          type: 'info',
          title: 'New Member',
          message: "#{member.display_name} joined #{group.name}",
          group_id: group.id
        })
      end

      GroupChannel.broadcast_to_group(group, {
        type: 'info',
        title: 'New Member',
        message: "#{member.display_name} joined the group",
        reload: true
      })
    end
  end
end
