require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "#valid?" do
    subject {tested_object.valid?}
    let(:tested_object) {Order.new(params)}

    context "Order.new" do
      let(:default_params) {
        {
          sender_name: "some name", 
          sender_contact: "some contact", 
          sender_address_line1: "some address line", 
          sender_address_city: "some city", 
          sender_address_state: "some state", 
          sender_address_postal_code: "12345", 
          sender_address_country_alpha2: "some country", 
          receiver_name: "some name", 
          receiver_contact: "some contact", 
          receiver_address_line1: "some address line", 
          receiver_address_city: "some city", 
          receiver_address_state: "some state", 
          receiver_address_postal_code: "54321", 
          receiver_address_country_alpha2: "some country", 
          receiver_email: "some.email@somedomain.com", 
          directlink_info: "some info", 
          shipping_fee: "10.5", 
          parcel_length: "1.2", 
          parcel_width: "1.3", 
          parcel_height: "1.4", 
          parcel_weight: "1.5", 
          parcel_content: "some content description", 
          tracking_number: "46799-79684544", 
          tracking_url: "some-url", 
          ship_status: "unship", 
          order_items_size: "1", 
          order_items: [
            OrderItem.new(
              quantity: "1", 
              sku: "2001", 
              selling_price: "35.0", 
              selling_price_currency: "1", 
              weight: "2.5", 
              description: "some description", 
              country_alpha2: "some country"
            )
          ]
        }
      }

      context "should be valid when all attributes are valid" do
        let(:params) {default_params}
        it {is_expected.to eq(true)}
      end
      context "should be valid when directlink_info is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:directlink_info)
          req_params
        }

        it {is_expected.to eq(true)}
      end
      context "should not be valid when sender_name is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_name)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_contact is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_contact)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_address_line1 is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_address_line1)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_address_city is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_address_city)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_address_state is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_address_state)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_address_postal_code is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_address_postal_code)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sender_address_country_alpha2 is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sender_address_country_alpha2)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_name is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_name)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_contact is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_contact)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_address_line1 is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_address_line1)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_address_city is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_address_city)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_address_state is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_address_state)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_address_postal_code is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_address_postal_code)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_address_country_alpha2 is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_address_country_alpha2)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when receiver_email is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:receiver_email)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when shipping_fee is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:shipping_fee)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_length is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:parcel_length)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_width is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:parcel_width)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_height is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:parcel_height)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_weight is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:parcel_weight)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_content is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:parcel_content)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when tracking_number is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:tracking_number)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when tracking_url is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:tracking_url)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when ship_status is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:ship_status)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when order_items_size is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:order_items_size)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when shipping_fee is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:shipping_fee] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when shipping_fee is less than 0" do
        let(:params) {
          req_params = default_params.clone
          req_params[:shipping_fee] = "-1.0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_length is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_length] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_length is less than 1" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_length] = "0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_width is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_width] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_width is less than 1" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_width] = "0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_height is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_height] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_height is less than 1" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_height] = "0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when parcel_weight is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:parcel_weight] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when ship_status is other than (unship, label_generated)" do
        let(:params) {
          req_params = default_params.clone
          req_params[:ship_status] = "pending"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when order_items_size is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:order_items_size] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when order_items_size is not an integer" do
        let(:params) {
          req_params = default_params.clone
          req_params[:order_items_size] = "2.0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when order_items_size is less than 0" do
        let(:params) {
          req_params = default_params.clone
          req_params[:order_items_size] = "-2"
          req_params
        }

        it {is_expected.to eq(false)}
      end
    end
  end
end
