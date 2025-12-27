class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.groups.includes(:users, :expenses)
    @total_balance = calculate_total_balance
    @total_you_owe = calculate_total_you_owe
    @total_owed_to_you = calculate_total_owed_to_you
    @friends_you_owe = calculate_friends_you_owe
    @friends_who_owe_you = calculate_friends_who_owe_you
    @recent_expenses = current_user.paid_expenses.includes(:group).order(created_at: :desc).limit(10)
  end

  private

  def calculate_total_balance
    current_user.groups.sum do |group|
      BalanceService.new(group).balance_for(current_user)
    end
  end

  def calculate_total_you_owe
    current_user.groups.sum do |group|
      BalanceService.new(group).you_owe(current_user)
    end
  end

  def calculate_total_owed_to_you
    current_user.groups.sum do |group|
      BalanceService.new(group).owed_to_you(current_user)
    end
  end

  def calculate_friends_you_owe
    debts = []
    current_user.groups.each do |group|
      service = BalanceService.new(group)
      service.debts_for(current_user).each do |debt|
        existing = debts.find { |d| d[:user].id == debt[:user].id }
        if existing
          existing[:amount] += debt[:amount]
        else
          debts << debt
        end
      end
    end
    debts.sort_by { |d| -d[:amount] }
  end

  def calculate_friends_who_owe_you
    credits = []
    current_user.groups.each do |group|
      service = BalanceService.new(group)
      service.credits_for(current_user).each do |credit|
        existing = credits.find { |c| c[:user].id == credit[:user].id }
        if existing
          existing[:amount] += credit[:amount]
        else
          credits << credit
        end
      end
    end
    credits.sort_by { |c| -c[:amount] }
  end
end
