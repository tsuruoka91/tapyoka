class Token::TransferForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :from_user, :integer
  attribute :to_user, :integer
  attribute :amount, :integer

  validates :from_user, presence: true
  validates :to_user, presence: true
  validates :amount, presence: true

  validate :amount_positive_integer?, if: -> { amount.present? }

  def initialize(params = {})
    super(params)
  end

  private

  def amount_positive_integer?
    unless amount > 0
      errors.add(:amount, 'must be positive integer')
    end
  end
end