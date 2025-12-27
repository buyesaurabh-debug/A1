class GroupChannel < ApplicationCable::Channel
  def subscribed
    @group = Group.find(params[:group_id])
    if @group.member?(current_user)
      stream_for @group
    else
      reject
    end
  end

  def unsubscribed
  end

  def self.broadcast_to_group(group, notification)
    broadcast_to(group, notification)
  end
end
