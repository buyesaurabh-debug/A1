class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy, :add_member, :remove_member]
  before_action :authorize_member!, only: [:show]
  before_action :authorize_admin!, only: [:edit, :update, :destroy, :add_member, :remove_member]

  def index
    @groups = current_user.groups
  end

  def show
    @balance_service = BalanceService.new(@group)
    @expenses = @group.expenses.includes(:payer, :expense_participants).order(created_at: :desc)
    @members = @group.users
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.admin = current_user

    if @group.save
      redirect_to @group, notice: 'Group was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'Group was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_url, notice: 'Group was successfully deleted.'
  end

  def add_member
    email = params[:email]&.strip&.downcase
    user = User.find_by(email: email)

    if user.nil?
      GroupMailer.invitation(@group, current_user, email).deliver_later
      redirect_to @group, notice: 'Invitation sent to the email address.'
    elsif @group.member?(user)
      redirect_to @group, alert: 'User is already a member.'
    else
      @group.add_member(user)
      GroupMailer.member_added(@group, user, current_user).deliver_later
      NotificationService.notify_member_added(@group, user, current_user)
      redirect_to @group, notice: 'Member added successfully.'
    end
  end

  def remove_member
    user = User.find(params[:user_id])

    if user == @group.admin
      redirect_to @group, alert: 'Cannot remove the group admin.'
    elsif @group.remove_member(user)
      redirect_to @group, notice: 'Member removed successfully.'
    else
      redirect_to @group, alert: 'Cannot remove member with outstanding balance.'
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def authorize_member!
    unless @group.member?(current_user)
      redirect_to groups_path, alert: 'You are not a member of this group.'
    end
  end

  def authorize_admin!
    unless @group.admin == current_user
      redirect_to @group, alert: 'Only the admin can perform this action.'
    end
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
