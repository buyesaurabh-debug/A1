class Settlement < ApplicationRecord
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'
  belongs_to :group

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :users_must_be_different
  validate :users_must_be_group_members

  private

  def users_must_be_different
    if from_user_id == to_user_id
      errors.add(:base, 'Cannot settle with yourself')
    end
  end

  def users_must_be_group_members
    return unless group
    unless group.member?(from_user)
      errors.add(:from_user, 'must be a member of the group')
    end
    unless group.member?(to_user)
      errors.add(:to_user, 'must be a member of the group')
    end
  end
end
