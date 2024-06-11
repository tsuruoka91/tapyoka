class Token::BurnForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :user, :integer
  attribute :amount, :integer
  attribute :memo, :string

  validates :user, presence: true
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