class Signature < ApplicationRecord
  belongs_to :professor
  has_one_attached :public_key
  attr_accessor :password
  attr_accessor :confirmation
  attr_accessor :private_key

  validates :professor_id, uniqueness: {message: "Solo una firma por profesor" }

end
