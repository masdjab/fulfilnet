FactoryBot.define do
  factory :order_item do
    id {nil}
    order_id {nil}
    quantity {1}
    sku {"1001001"}
    selling_price {"20.5"}
    selling_price_currency {1}
    weight {"1.5"}
    description {"some description"}
    country_alpha2 {"some country"}
    created_at {"2023-03-23T09:14:19.000Z"}
    updated_at {"2023-03-23T09:14:19.000Z"}
  end
  
  factory :order do
    id {nil}
    sender_name {"some name"}
    sender_contact {"some contact"}
    sender_address_line1 {"some address"}
    sender_address_city {"some city"}
    sender_address_state {"some state"}
    sender_address_postal_code {"12345"}
    sender_address_country_alpha2 {"some country"}
    receiver_name {"some name"}
    receiver_contact {"some contact"}
    receiver_address_line1 {"some address"}
    receiver_address_city {"some city"}
    receiver_address_state {"some state"}
    receiver_address_postal_code {"54321"}
    receiver_address_country_alpha2 {"some country"}
    receiver_email {"someemail@somedomain.com"}
    directlink_info {'{"status": "Success", "errors": null}'}
    shipping_fee {"10.2"}
    parcel_length {"1.2"}
    parcel_width {"1.3"}
    parcel_height {"1.4"}
    parcel_weight {"1.5"}
    parcel_content {"some content description"}
    order_items_size {1}
    tracking_number {"fdsaer-lw3j4ojaldsf"}
    tracking_url {"http://somedomain.com/somepath"}
    ship_status {"unship"}
    created_at {"2023-03-23T09:14:19.000Z"}
    updated_at {"2023-03-23T09:14:19.000Z"}
  end
end
