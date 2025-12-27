class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :authorize_member!
  before_action :set_expense, only: [:show, :edit, :update, :destroy]

  def index
    @expenses = @group.expenses.includes(:payer, :expense_participants).order(created_at: :desc)
  end

  def show
    @participants = @expense.expense_participants.includes(:user)
  end

  def new
    @expense = @group.expenses.build
    @expense.payer = current_user
    @members = @group.users
  end

  def create
    @expense = @group.expenses.build(expense_params)
    @expense.payer = current_user

    if @expense.save
      create_participants
      notify_participants_of_expense
      NotificationService.notify_expense_created(@expense)
      redirect_to group_expense_path(@group, @expense), notice: 'Expense was successfully created.'
    else
      @members = @group.users
      render :new
    end
  end

  def edit
    @members = @group.users
  end

  def update
    if @expense.update(expense_params)
      @expense.expense_participants.destroy_all
      create_participants
      redirect_to group_expense_path(@group, @expense), notice: 'Expense was successfully updated.'
    else
      @members = @group.users
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to group_expenses_path(@group), notice: 'Expense was successfully deleted.'
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_expense
    @expense = @group.expenses.find(params[:id])
  end

  def authorize_member!
    unless @group.member?(current_user)
      redirect_to groups_path, alert: 'You are not a member of this group.'
    end
  end

  def expense_params
    params.require(:expense).permit(:description, :total_amount, :tax)
  end

  def create_participants
    split_type = params[:split_type] || 'equal'
    participant_ids = params[:participant_ids] || []
    participant_shares = params[:participant_shares] || {}

    members_to_split = if participant_ids.present?
      @group.users.where(id: participant_ids)
    else
      @group.users
    end

    case split_type
    when 'equal'
      share_amount = (@expense.total_amount / members_to_split.count).round(2)
      members_to_split.each do |member|
        @expense.expense_participants.create(user: member, share_amount: share_amount)
      end
    when 'custom'
      members_to_split.each do |member|
        share = participant_shares[member.id.to_s].to_f
        @expense.expense_participants.create(user: member, share_amount: share) if share > 0
      end
    end
  end

  def notify_participants_of_expense
    @expense.expense_participants.includes(:user).each do |participant|
      next if participant.user == current_user
      GroupMailer.new_expense(@expense, participant.user).deliver_later
    end
  end
end
