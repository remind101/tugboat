Warden::Manager.serialize_into_session do |user|
  user.uid
end

Warden::Manager.serialize_from_session do |uid|
  User.find(uid)
end

Warden::Strategies.add(:apikey) do

  def valid?
    apikey
  end

  def authenticate!
    if user = User.where(uid: uid).first_or_create
      success! user
    else
      fail!
    end
  end

private

  def uid
    raw_user['id'].gsub(/@.*/, '').to_i
  end

  def raw_user
    @raw_user ||= client.get_user.body
  end

  def client
    @client ||= Heroku::API.new(api_key: apikey)
  end

  def apikey
    params['apikey']
  end

end
