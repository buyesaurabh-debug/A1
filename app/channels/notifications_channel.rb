class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
  end

  def self.broadcast_to_user(user, notification)
    broadcast_to(user, notification)
  end
end
