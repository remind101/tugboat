class User < ActiveRecord::Base
  self.primary_key = :uid

  before_create do
    # TODO: Generate a real SSH key and post the public key to Heroku.
    self.ssh_key = SecureRandom.hex
  end
end
