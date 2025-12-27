class GroupMailer < ApplicationMailer
  def invitation(group, invited_by, email)
    @group = group
    @invited_by = invited_by
    @email = email
    @signup_url = new_user_registration_url

    mail(
      to: email,
      subject: "#{invited_by.display_name} invited you to join #{group.name} on Splitwise"
    )
  end

  def member_added(group, member, added_by)
    @group = group
    @member = member
    @added_by = added_by
    @group_url = group_url(group)

    mail(
      to: member.email,
      subject: "You've been added to #{group.name} on Splitwise"
    )
  end

  def new_expense(expense, recipient)
    @expense = expense
    @recipient = recipient
    @payer = expense.payer
    @group = expense.group
    @group_url = group_url(@group)

    mail(
      to: recipient.email,
      subject: "New expense in #{@group.name}: #{@expense.description}"
    )
  end

  def new_settlement(settlement, recipient)
    @settlement = settlement
    @recipient = recipient
    @group = settlement.group
    @group_url = group_url(@group)

    mail(
      to: recipient.email,
      subject: "Settlement recorded in #{@group.name}"
    )
  end
end
