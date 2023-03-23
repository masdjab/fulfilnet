require 'webmock'

include WebMock::API
WebMock.enable!


class OrdersController < ApplicationController
  ORDERS_PER_PAGE = 20

  before_action :validate_create_request_parameters, only: [:create]

  def create
    order = Order.new
    order.sender_name = params[:sender_name]
    order.sender_contact = params[:sender_contact]
    order.sender_address_line1 = params[:sender_address_line1]
    order.sender_address_city = params[:sender_address_city]
    order.sender_address_state = params[:sender_address_state]
    order.sender_address_postal_code = params[:sender_address_postal_code]
    order.sender_address_country_alpha2 = params[:sender_address_country]
    order.receiver_name = params[:receiver_name]
    order.receiver_contact = params[:receiver_contact]
    order.receiver_address_line1 = params[:receiver_address_line1]
    order.receiver_address_city = params[:receiver_address_city]
    order.receiver_address_state = params[:receiver_address_state]
    order.receiver_address_postal_code = params[:receiver_address_postal_code]
    order.receiver_address_country_alpha2 = params[:receiver_address_country]
    order.receiver_email = params[:receiver_email]
    order.shipping_fee = params[:shipping_fee]
    order.parcel_length = params[:parcel_length]
    order.parcel_width = params[:parcel_width]
    order.parcel_height = params[:parcel_height]
    order.parcel_weight = params[:parcel_weight]
    order.parcel_content = params[:parcel_content]
    order.tracking_number = params[:tracking_number]
    order.tracking_url = params[:tracking_url]
    order.ship_status = params[:ship_status]
    order.order_items_size = params[:order_items].count
    order.order_items = params[:order_items].map do |item_data|
      order_item = OrderItem.new
      order_item.quantity = item_data[:quantity]
      order_item.sku = item_data[:sku]
      order_item.selling_price = item_data[:selling_price]
      order_item.selling_price_currency = item_data[:selling_price_currency]
      order_item.weight = item_data[:weight]
      order_item.description = item_data[:description]
      order_item.country_alpha2 = item_data[:country_alpha2]
      order_item
    end

    directlink_info = ""
    if params[:sync_to_directlink] == "true"
      directlink_info = create_shipping_order(order)
    end
    order.directlink_info = directlink_info

    if order.save
      render_success format_order(order), false
    else
      error_details = order.errors.details
      if !error_details.empty?
        message = "Invalid value for [#{error_details.keys.join(", ")}]"
        render_error :bad_request, message, false
      else
        message = "Unknown error occured"
        render_error :internal_server_error, message, false
      end
    end
  end
  def search
    search_offset = 0
    search_limit = ORDERS_PER_PAGE
    order_criteria = {}
    item_criteria = {}

    if params.key?(:sku)
      item_criteria["order_items.sku"] = params[:sku]
    end
    if params.key?(:tracking_number)
      order_criteria[:tracking_number] = params[:tracking_number]
    end
    if params.key?(:ship_status)
      order_criteria[:ship_status] = params[:ship_status]
    end
    if params.key?(:created_at_from) || params.key?(:created_at_to)
      if !params.key?(:created_at_from)
        render_error :bad_request, "Missing parameter 'created_at_from'", true
        return
      end
      if !params.key?(:created_at_to)
        render_error :bad_request, "Missing parameter 'created_at_to'", true
        return
      end

      created_at_from = string_to_datetime(params[:created_at_from])
      if created_at_from.nil?
        render_error :bad_request, "Invalid value for 'created_at_from'", true
        return
      end

      created_at_to = string_to_datetime(params[:created_at_to])
      if created_at_to.nil?
        render_error :bad_request, "Invalid value for 'created_at_to'", true
        return
      end

      if created_at_to < created_at_from
        render_error :bad_request, "Incorrect range for 'created_at_from' and 'created_at_to'", true
        return
      end

      order_criteria[:created_at] = created_at_from..created_at_to
    end
    if params.key?(:page)
      if params[:page].to_i.to_s != params[:page]
        render_error :bad_request, "Parameter 'page' must be integer", true
        return
      elsif params[:page].to_i < 0
        render_error :bad_request, "Parameter 'page' must not less than 0", true
        return
      else
        search_offset = params[:page].to_i * ORDERS_PER_PAGE
      end
    end
    if params.key?(:limit)
      if params[:limit].to_i.to_s != params[:limit]
        render_error :bad_request, "Parameter 'limit' must be integer", true
        return
      elsif params[:limit].to_i <= 0
        render_error :bad_request, "Parameter 'limit' must greater than 0", true
        return
      else
        search_limit = params[:limit].to_i
      end
    end

    orders = Order
      .where(order_criteria)
      .limit(search_limit)
      .offset(search_offset)
      .includes(:order_items)
      .where(item_criteria)
    result = orders.map{|order|format_order(order)}
    render_success result, true
  end

  private
  def string_to_datetime(value)
    begin
      value.to_datetime
    rescue Exception
      nil
    end
  end
  def required_order_params
    %i[sync_to_directlink sender_name sender_contact sender_address_line1 
      sender_address_city sender_address_state sender_address_postal_code 
      sender_address_country receiver_name receiver_contact receiver_address_line1 
      receiver_address_city receiver_address_state receiver_address_postal_code 
      receiver_address_country receiver_email shipping_fee parcel_length 
      parcel_width parcel_height parcel_weight parcel_content tracking_number 
      tracking_url ship_status order_items]
  end
  def required_order_item_params
    %i[quantity sku selling_price selling_price_currency weight description country_alpha2]
  end
  def validate_create_request_parameters
    missing_keys = required_order_params.select{|k|!params.key?(k)}
    if !missing_keys.empty?
      render_error :bad_request, "Missing parameters [#{missing_keys.join(", ")}] for order", false
      return
    end

    params[:order_items].each do |order_item|
      missing_keys = required_order_item_params.select{|k|!order_item.key?(k)}
      if !missing_keys.empty?
        render_error :bad_request, "Missing parameters [#{missing_keys.join(", ")}] for order_item", false
        return
      end
    end
  end
  def format_order(order)
    order_info = order.attributes
    order_info["order_items"] = order.order_items.map{|i|i.attributes}
    if !order.directlink_info.empty?
      order_info["directlink_info"] = JSON.parse(order.directlink_info)
    end
    order_info
  end
  def render_error(status, message, is_multi_rows)
    response = {status: "Error", message: message}

    if is_multi_rows
      response[:orders] = nil
    else
      response[:order] = nil
    end
  
    render json: response, status: status
  end
  def render_success(result, is_multi_rows)
    response = {status: "Success", message: ""}

    if is_multi_rows
      response[:orders] = result
    else
      response[:order] = result
    end

    render json: response
  end
  def create_shipping_order(order)
    # Headers example:
    # Content-Type: application/json
    # Accept: application/json
    # User Agent: Mozilla 5.0
    # Host: qa.etowertech.com
    # X-WallTech-Date: Thu, 06 Aug 2020 06:01:26 GMT
    # Authorization: WallTech testLvs2jdug2qIoRsJyuxs:2THPh5_j4OTYUGdinstTC4nYqDE=
  
    shipping_order_url = "http://www.etowertech.com/services/shipper/orders"
    
    request_body = '[
      {
        "referenceNo":"TEST20201223",
        "trackingNo":"",
        "serviceCode":"UBI.CN2UKE2E.ROM",
        "incoterm":"",
        "description":"smartwristband",
        "nativeDescription":"智能手环",
        "weight":0.02,
        "weightUnit":"KG",
        "length":50,
        "width":40,
        "height":30,
        "volume":0.06,
        "dimensionUnit":"CM",
        "invoiceValue":1,
        "invoiceCurrency":"EUR",
        "pickupType":"",
        "authorityToLeave":"",
        "lockerService":"",
        "batteryType":"Lithium Ion Polymer",
        "batteryPacking":"Inside Equipment",
        "dangerousGoods":"false",
        "serviceOption":"",
        "instruction":"",
        "facility":"",
        "platform":"",
        "recipientName":"RohitPatel",
        "recipientCompany":"RohitPatel",
        "phone":"0433813492",
        "email":"prohit9@yahoo.com",
        "addressLine1":"71 Clayhill Drive ",
        "addressLine2":"",
        "addressLine3":"",
        "city":"Yate, Bristol",
        "state":"Yate, Bristol",
        "postcode":"BS37 7DA",
        "country":"GB",
        "shipperName":"",
        "shipperPhone":"",
        "shipperAddressLine1":"",
        "shipperAddressLine2":"",
        "shipperAddressLine3":"",
        "shipperCity":"",
        "shipperState":"",
        "shipperPostcode":"",
        "shipperCountry":"",
        "returnOption":"",
        "returnName":"",
        "returnAddressLine1":"",
        "returnAddressLine2":"",
        "returnAddressLine3":"",
        "returnCity":"",
        "returnState":"",
        "returnPostcode":"",
        "returnCountry":"",
        "abnnumber":"",
        "gstexemptioncode":"",
        "orderItems":[
          {
            "itemNo":"283856695918",
            "sku":"S8559024940",
            "description":"smartwristband",
            "nativeDescription":"智能手环",
            "hsCode":"",
            "originCountry":"CN",
            "itemCount":"1",
            "unitValue":1,
            "warehouseNo":"",
            "productURL":"",
            "weight":"0.020"
          }
        ],
        "extendData":{
          "agentID":"TEST",
          "vendorid":"GB123456789",
          "platformorderno":"123456"
        }
      }
    ]'
  
    success_response = '{
      "status": "Success",
      "errors": null,
      "data": [
        {
          "status": "Success",
          "errors": null,
          "warnings": [
            {
              "code": 130066,
              "message": "Shipments over 20CAD to Canada will incur import duty and tax"
            }
          ],
          "orderId": "jq2m2GT7-qWbRdqwvui78w",
          "referenceNo": "Sammy2021601084157",
          "trackingNo": "4006318030131208",
          "connoteId": null
        }
      ],
      "warnings": [
        {
          "code": 130066,
          "message": "Shipments over 20CAD to Canada will incur import duty and tax"
        }
      ]
    }'
  
    stub_request(:post, shipping_order_url).to_return(body: success_response, status: 200)
  
    uri = URI.parse(shipping_order_url)
    http = Net::HTTP.new(uri.host, uri.port)
    headers = {'Content-Type': 'application/json'}
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = request_body
    response = http.request(request)
    response.body
  end
end
