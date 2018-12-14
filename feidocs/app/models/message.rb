class Message < ApplicationRecord
  belongs_to :professor
  belongs_to :conversation
end
