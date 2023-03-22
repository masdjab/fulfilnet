class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string    :sender_name
      t.string    :sender_contact
      t.string    :sender_address_line1
      t.string    :sender_address_city
      t.string    :sender_address_state
      t.string    :sender_address_postal_code
      t.string    :sender_address_country_alpha2
      t.string    :receiver_name
      t.string    :receiver_contact
      t.string    :receiver_address_line1
      t.string    :receiver_address_city
      t.string    :receiver_address_state
      t.string    :receiver_address_postal_code
      t.string    :receiver_address_country_alpha2
      t.string    :receiver_email
      t.string    :directlink_info
      t.decimal   :shipping_fee
      t.decimal   :parcel_length
      t.decimal   :parcel_width
      t.decimal   :parcel_height
      t.decimal   :parcel_weight
      t.string    :parcel_content
      t.integer   :order_items_size
      t.string    :tracking_number
      t.string    :tracking_url
      t.string    :ship_status
      t.timestamps
    end
  end
end
