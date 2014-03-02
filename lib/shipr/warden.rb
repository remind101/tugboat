Warden::Strategies.add(:basic) do
  def auth
    @auth ||= Rack::Auth::Basic::Request.new(env)
  end

  def authenticate!
    return fail! unless auth.provided?
    return fail!(:bad_request) unless auth.basic?
    username, password = auth.credentials
    password == Shipr.configuration.auth_token ? success!('root') : fail!
  end

  def store?
    false
  end
end
