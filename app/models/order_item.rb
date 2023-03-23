class OrderItem < ApplicationRecord
  SKIP_VALIDATE_FIELDS = ["id", "order_id", "created_at", "updated_at"]
  MUST_VALIDATE_FIELDS = OrderItem.attribute_names - SKIP_VALIDATE_FIELDS

  belongs_to :order

  validates_presence_of MUST_VALIDATE_FIELDS
  validates_numericality_of :quantity, greater_than: 0, only_integer: true
  validates_numericality_of :selling_price, greater_than_or_equal_to: 0
  validates_numericality_of :selling_price_currency, only_integer: true, in: 1..2
  validates_numericality_of :weight, greater_than_or_equal_to: 0
end
