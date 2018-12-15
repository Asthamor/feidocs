module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_professor

    def connect
      self.current_professor = find_verified_user
    end

    protected

    def find_verified_user
      if (current_professor = env['warden'].user)
        current_professor
      else
        reject_unauthorized_connection
      end
    end
  end
end
