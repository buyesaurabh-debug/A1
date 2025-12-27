class Group < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: 'admin_id'
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :expenses, dependent: :destroy
  has_many :settlements, dependent: :destroy

  validates :name, presence: true

  after_create :add_admin_as_member

  def member?(user)
    group_memberships.exists?(user: user)
  end

  def add_member(user)
    group_memberships.find_or_create_by(user: user)
  end

  def remove_member(user)
    return false if user == admin
    membership = group_memberships.find_by(user: user)
    return false unless membership
    membership.destroy
  end

  private

  def add_admin_as_member
    add_member(admin)
  end
end
