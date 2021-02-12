class AuthenticationUtil
  def self.authenticate(username:, password:)
    Account.find_by(username: username, auth_id: password)
  end
end