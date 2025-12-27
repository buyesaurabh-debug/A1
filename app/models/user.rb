class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :administered_groups, class_name: 'Group', foreign_key: 'admin_id', dependent: :nullify
  has_many :paid_expenses, class_name: 'Expense', foreign_key: 'payer_id'
  has_many :expense_participants, dependent: :destroy

  def display_name
    name.presence || email.split('@').first
  end
end
