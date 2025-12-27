class SettlementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :authorize_member!

  def new
    @settlement = @group.settlements.build
    @members = @group.users.where.not(id: current_user.id)
    @balance_service = BalanceService.new(@group)
  end

  def create
    @settlement = @group.settlements.build(settlement_params)
    @settlement.from_user = current_user

    if @settlement.save
      GroupMailer.new_settlement(@settlement, @settlement.to_user).deliver_later
      NotificationService.notify_settlement_created(@settlement)
      redirect_to @group, notice: 'Settlement recorded successfully.'
    else
      @members = @group.users.where.not(id: current_user.id)
      @balance_service = BalanceService.new(@group)
      render :new
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def authorize_member!
    unless @group.member?(current_user)
      redirect_to groups_path, alert: 'You are not a member of this group.'
    end
  end

  def settlement_params
    params.require(:settlement).permit(:to_user_id, :amount, :note)
  end
end
