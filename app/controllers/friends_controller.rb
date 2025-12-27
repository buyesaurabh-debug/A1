class FriendsController < ApplicationController
  before_action :authenticate_user!

  def show
    @friend = User.find(params[:id])
    @shared_groups = current_user.groups.joins(:group_memberships)
                                        .where(group_memberships: { user_id: @friend.id })

    @shared_expenses = []
    @shared_groups.each do |group|
      group.expenses.includes(:payer, :expense_participants).each do |expense|
        if expense.payer == @friend || expense.participants.include?(@friend)
          @shared_expenses << { group: group, expense: expense }
        end
      end
    end
    @shared_expenses.sort_by! { |e| -e[:expense].created_at.to_i }
  end
end
