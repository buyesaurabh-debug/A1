module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      verified_user = find_user_from_warden || find_user_from_session
      if verified_user
        verified_user
      else
        reject_unauthorized_connection
      end
    end

    def find_user_from_warden
      env['warden']&.user
    rescue
      nil
    end

    def find_user_from_session
      session = cookies.encrypted[Rails.application.config.session_options[:key]]
      return nil unless session

      warden_key = session['warden.user.user.key']
      return nil unless warden_key

      user_id = warden_key[0][0]
      User.find_by(id: user_id)
    rescue
      nil
    end
  end
end
