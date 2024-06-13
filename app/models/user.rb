class User < ApplicationRecord
  has_many :transactions

  enum role: { user: 0, admin: 1 }

  def amount
    res = TapyrusApi.get_token(ENV['TOKEN_ID'], access_token: access_token)
    pp res
    pp res[:outputs].map{_1[:amount]}.sum
  end
end
