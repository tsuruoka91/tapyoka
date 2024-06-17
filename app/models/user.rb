class User < ApplicationRecord
  has_many :transactions

  enum role: { user: 0, admin: 1 }

  def amount_by_blockchain
    res = TapyrusApi.get_token(ENV['TOKEN_ID'], access_token: access_token)
    pp res
    res[:outputs].map{_1[:amount]}.sum
  end
end
