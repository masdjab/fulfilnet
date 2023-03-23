class Order < ApplicationRecord
  SKIP_VALIDATE_FIELDS = ["id", "created_at", "updated_at", "directlink_info"]
  MUST_VALIDATE_FIELDS = Order.attribute_names - SKIP_VALIDATE_FIELDS

  has_many :order_items
  
  validates_presence_of MUST_VALIDATE_FIELDS
  validates_numericality_of :shipping_fee, :greater_than_or_equal_to => 0
  validates_numericality_of :parcel_length, :greater_than => 0
  validates_numericality_of :parcel_width, :greater_than => 0
  validates_numericality_of :parcel_height, :greater_than => 0
  validates_numericality_of :parcel_weight, :greater_than => 0
  validates_numericality_of :order_items_size, :greater_than_or_equal_to => 0, :only_integer => true
  validates_inclusion_of :ship_status, in: ["unship", "label_generated"]
end
