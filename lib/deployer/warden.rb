Warden::Manager.serialize_into_session do |user|
  user.uid
end

Warden::Manager.serialize_from_session do |uid|
  User.find(uid)
end
