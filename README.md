# Backend Challenge - DirectLink
## Introduction

Hi! This is your first day at Fulfilnet. We already have a few tasks for you, so let's get started!

Stashworks's Web-based Software(Fulfilnet) lets merchant manage orders easily, and also make warehouse staff lives easier by offering a simple WMS system.

To ship a parcel, one of the main flow is

1. Create shipment/order to third-party provider via API
2. Buy label for the shipment/order

Your first project is to integrate with Directlink.

API documentation is here: https://www.dropbox.com/s/5epw7na3oye22y5/Directlink-API-V7.4.pdf?dl=0

## Guidelines (PLEASE READ IT CAREFULLY & MUST FOLLOW THE GUIDELINES)

- Please create a private repository in Github and share it with `fulfilnet` (this is our Github user ID)
- All developers make mistakes, so there may be some bugs in our app. If something seems abnormal, it's probably because one of our developers made a mistake. Read the code carefully, fix any bugs you find and feel free to suggest changes to make the code cleaner.
- Each feature you need create a new branch, either off `master` or `another branch` that you believe is more appropriate and **make sure it's easy to review for reviewer**, and create a pull request when you are done and assign to `fulfilnet` to review.
- To ensure your code adheres to the desired functionality, please write tests using `rspec`.
- You DON'T NEED TO MAKE REAL API CALL / Getting an API key can use `webmock`
- We already separate frontend and backend, and we communicate using **JSON** format.
- You have 3 days to finish the quiz, if any questions, feel free to ask us.

# Tasks

## Task 1 - Preapre database

Please create a table called `orders` to store orders
and the schema should look like below, if missing feel free to add more columns.

```ruby
# == Schema Information
#
# Table name: orders
#
#  id                                     :uuid             not null, primary key
#  sender_name                            :string
#  sender_contact                         :string
#  sender_address_line1                   :string
#  sender_address_city                    :string
#  sender_address_state                   :string
#  sender_address_postal_code             :string
#  sender_address_country_alpha2          :string # ISO 3166
#  receiver_name                          :string
#  receiver_contact                       :string
#  receiver_address_line1                 :string
#  receiver_address_city                  :string
#  receiver_address_state                 :string
#  receiver_address_postal_code           :string
#  receiver_address_country_alpha2        :string # ISO 3166
#  receiver_email                         :string
#  directlink_info                        :jsonb
#  shipping_fee                           :decimal
#  parcel_length                          :decimal # always store in CM
#  parcel_width                           :decimal # always store in CM
#  parcel_height                          :decimal # always store in CM
#  parcel_weight                          :decimal # always store in KG
#  parcel_content                         :string
#  order_items_size                       :integer # order_items size
#  tracking_number                        :string
#  tracking_url                           :string
#  ship_status                            :string # unship/label_generated
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
```

in the future, we will need to search order by ship_status, ...etc (check task 3)

and please create a table called `order_items` to store order items
and the schema should look like below, if missing feel free to add more columns.

```ruby
# == Schema Information
#
# Table name: order_items
#
#  id                           :bigint           not null, primary key
#  quantity                     :integer
#  sku                          :string
#  selling_price                :decimal(, )
#  selling_price_currency       :integer     # 1: SGD, 2: IDR
#  weight                       :decimal(, ) # always store in KG
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  order_id                     :uuid
#  description                  :string
#  country_alpha2               :string
```

## Task 2 - Create order and sync to Directlink via API

Please create an endpoint to handle requests from FE.

the request body should look like this:

```ruby
POST ../orders

{
  sync_to_directlink
  sender_name
  sender_contact
  sender_address_line1
  sender_address_city
  sender_address_state
  sender_address_postal_code
  sender_address_country
  receiver_name
  receiver_contact
  receiver_address_line1
  receiver_address_city
  receiver_address_state
  receiver_address_postal_code
  receiver_address_country
  parcel_length
  parcel_width
  parcel_height
  parcel_weight
  order_items: [
    {
      quantity
      sku
      .... # similiar to order item
    }
  ]
  ... # similiar to order
}
```

it will do 3 actions,

1. create an order in our database. Please consider validation.
2. make api call to Directlink to create order (#Create Shipping Orders) if `sync_to_directlink = true`
3. save necessary info into `directlink_info` if `sync_to_directlink = true`

the response body we send back to FE should look like:

```ruby
{
  "status": "Success",
  "message": "xxxxx",
  "order": {
    id
    sender_name
    sender_contact
    sender_address_line1
    sender_address_city
    sender_address_state
    sender_address_postal_code
    sender_address_country_alpha2
    receiver_name
    receiver_contact
    receiver_address_line1
    receiver_address_city
    receiver_address_state
    receiver_address_postal_code
    receiver_address_country_alpha2
    receiver_email
    directlink_info: {
      "status": "Success",
      "errors": nil,
      "data": [
        {
          "status": "Success",
          "errors": nil,
          "warnings": [
            {
              "code": 130066,
              "message": "Shipments over 20CAD to Canada will incur import duty and tax"
            }
          ],
          "orderId": "jq2m2GT7-qWbRdqwvui78w",
          "referenceNo": "Sammy2021601084157",
          "trackingNo": "4006318030131208",
          "connoteId": nil
        }
      ]
    }
    order_items: [
      {
        quantity
        sku
        .... # similiar to order item
      }
    ]
    shipping_fee
    parcel_length
    parcel_width
    parcel_height
    parcel_weight
    parcel_content
    order_items_size
    tracking_number
    tracking_url
    ship_status
    created_at      # 2023/03/21 15:00:00Z
    updated_at
  }
}
```

## Task 3 - Search orders

Please create an endpoint to handle requests from FE.

the request body should look like this:

```ruby
GET ../orders

{
  tracking_number
  ship_status
  created_at_from
  created_at_to
  sku
  limit
  page
}
```
it will find all match orders and return orders and its order_items

the response body we send back to FE should look like:

```ruby
{
  "status": "Success",
  "message": "xxxxx",
  "orders": [{
    id
    sender_name
    sender_contact
    sender_address_line1
    sender_address_city
    sender_address_state
    sender_address_postal_code
    sender_address_country_alpha2
    receiver_name
    receiver_contact
    receiver_address_line1
    receiver_address_city
    receiver_address_state
    receiver_address_postal_code
    receiver_address_country_alpha2
    receiver_email
    directlink_info: {
      "status": "Success",
      "errors": nil,
      "data": [
        {
          "status": "Success",
          "errors": nil,
          "warnings": [
            {
              "code": 130066,
              "message": "Shipments over 20CAD to Canada will incur import duty and tax"
            }
          ],
          "orderId": "jq2m2GT7-qWbRdqwvui78w",
          "referenceNo": "Sammy2021601084157",
          "trackingNo": "4006318030131208",
          "connoteId": nil
        }
      ]
    }
    order_items: [
      {
        quantity
        sku
        .... # similiar to order item
      }
    ]
    shipping_fee
    parcel_length
    parcel_width
    parcel_height
    parcel_weight
    parcel_content
    order_items_size
    tracking_number
    tracking_url
    ship_status
    created_at      # 2023/03/21 15:00:00Z
    updated_at
  }]
}
```


