class OrdersController < ApplicationController
  DEFAULT_SEARCH_LIMIT = 20

  before_action :validate_create_request_parameters, only: [:create]

  def create
    # todo: use webmock to mock API request to directlink
    directlink_info = "{\"status\": \"success\", \"errors\": null, \"data\": {}}"

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
    order.directlink_info = directlink_info
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

    if order.save
      render_success format_order(order), false
    else
      render_error :internal_error, "Unknown error occured", false
    end
  end
  def search
    search_offset = 0
    search_limit = DEFAULT_SEARCH_LIMIT
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
        render_error :bad_request, "Missing parameter 'created_at_from'"
        return
      end
      if !params.key?(:created_at_to)
        render_error :bad_request, "Missing parameter 'created_at_to'"
        return
      end

      created_at_from = string_to_datetime(params[:created_at_from])
      if created_at_from.nil?
        render_error :bad_request, "Invalid value for 'created_at_from'"
        return
      end

      created_at_to = string_to_datetime(params[:created_at_to])
      if created_at_to.nil?
        render_error :bad_request, "Invalid value for 'created_at_to'"
        return
      end

      if created_at_to < created_at_from
        render_error :bad_request, "Incorrect range for 'created_at_from' and 'created_at_to'"
        return
      end

      order_criteria[:created_at] = created_at_from..created_at_to
    end
    if params.key?(:page)
      if params[:page].to_i.to_s != params[:page]
        render_error :bad_request, "Parameter 'page' must be integer"
        return
      else
        search_offset = params[:page].to_i
      end
    end
    if params.key?(:limit)
      if params[:limit].to_i.to_s != params[:limit]
        render_error :bad_request, "Parameter 'limit' must be integer"
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
    order_info["directlink_info"] = JSON.parse(order.directlink_info)
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
end
