require 'rails_helper'

RSpec.describe "Orders", type: :request do
  describe "POST /orders" do
    context "create new order" do
      let(:request_params) {
        {
          sync_to_directlink: true, 
          sender_name: "some name", 
          sender_contact: "some contact", 
          sender_address_line1: "some address", 
          sender_address_city: "some city", 
          sender_address_state: "some state", 
          sender_address_postal_code: "12345", 
          sender_address_country: "some country", 
          receiver_name: "some name", 
          receiver_contact: "some contact", 
          receiver_address_line1: "some address", 
          receiver_address_city: "some city", 
          receiver_address_state: "some state", 
          receiver_address_postal_code: "54321", 
          receiver_address_country: "some country", 
          receiver_email: "someemail@somedomain.com", 
          shipping_fee: 10.2, 
          parcel_length: 1.2, 
          parcel_width: 1.3, 
          parcel_height: 1.4, 
          parcel_weight: 1.5, 
          parcel_content: "some content description", 
          tracking_number: "fdsaer-lw3j4ojaldsf", 
          tracking_url: "http://somedomain.com/somepath", 
          ship_status: "unship", 
          order_items_size: 2, 
          order_items: [
            {
              quantity: 1, 
              sku: "3001", 
              selling_price: 20.5, 
              selling_price_currency: 1, 
              weight: 1.2, 
              description: "some description", 
              country_alpha2: "some country"
            }, 
            {
              quantity: 2, 
              sku: "3002", 
              selling_price: 30.6, 
              selling_price_currency: 1, 
              weight: 2.2, 
              description: "some description", 
              country_alpha2: "some country"
            }
          ]
        }
      }

      context "when one or more of required order params is missing" do
        it 'should return bad request' do
          post "/orders", params: request_params.select{|k,v|k != :sync_to_directlink}
          expect(response.status).to eq(400)
        end
      end
      context "when one or more of required order_item params is missing" do
        it 'should return bad request' do
          parameters = request_params.clone
          parameters[:order_items][0].delete(:quantity)
          post "/orders", params: parameters
          expect(response.status).to eq(400)
        end
      end
      context "when order and order_items params provided" do
        context "when failed saving order" do
          context "when order validation errors occured" do
            it "should return bad request" do
              parameters = request_params.clone
              parameters[:ship_status] = "pending"
              expected_response = {
                status: "Error", 
                message: "Invalid value for [ship_status]", 
                order: nil
              }
              post "/orders", params: parameters
              expect(response.status).to eq(400)
              expect(response.body).to eq(expected_response.to_json)
            end
          end
          context "when other error occured" do
            it "should return internal_server_error" do
              expected_response = {
                status: "Error", 
                message: "Unknown error occured", 
                order: nil
              }
              allow_any_instance_of(Order).to receive(:save).and_return(false)
              post "/orders", params: request_params
              expect(response.status).to eq(500)
              expect(response.body).to eq(expected_response.to_json)
            end
          end
        end
        context "when order saved successfully" do
          context "when sync_to_directlink is false" do
            it "should not send API request to directlink" do
              parameters = request_params.clone
              parameters[:sync_to_directlink] = false
              expect_any_instance_of(OrdersController).to_not receive(:create_shipping_order)
              post "/orders", params: parameters
              expect(response.status).to eq(200)
              response_body_hash = JSON.parse(response.body)
              expect(response_body_hash["order"]["order_items_size"]).to eq(2)
              expect(response_body_hash["order"]["order_items"][0]["sku"]).to eq("3001")
              expect(response_body_hash["order"]["order_items"][1]["sku"]).to eq("3002")
            end
          end
          context "when sync_to_directlink is true" do
            it "should send API request to directlink" do
              directlink_info = "{\"status\": \"Success\", \"errors\": null}"
              expect_any_instance_of(OrdersController).to receive(:create_shipping_order).and_return(directlink_info)
              post "/orders", params: request_params
              expect(response.status).to eq(200)
              response_body_hash = JSON.parse(response.body)
              expect(response_body_hash["order"]["order_items_size"]).to eq(2)
              expect(response_body_hash["order"]["order_items"][0]["sku"]).to eq("3001")
              expect(response_body_hash["order"]["order_items"][1]["sku"]).to eq("3002")
            end
          end
        end
      end
    end
  end

  describe "GET /orders" do
    context "when no params provided" do
      it "should returns success" do
        FactoryBot.create(:order) do |order|
          FactoryBot.create(:order_item, order: order)
        end

        order = FactoryBot.attributes_for(:order, id: 1)
        order[:directlink_info] = JSON.parse(order[:directlink_info])
        order[:order_items] = [
          FactoryBot.attributes_for(:order_item, id: 1, order_id: 1)
        ]

        expected_response = {
          status: "Success", 
          message: "", 
          orders: [order]
        }

        get "/orders"
        expect(response.status).to eq(200)
        expect(response.body).to eq(expected_response.to_json)
      end
    end
    context "when params provided" do
      let!(:orders) {
        FactoryBot.create(
          :order, 
          id: 1, 
          tracking_number: "100-2001", 
          ship_status: "unship", 
          created_at: "2023-03-15T00:00:00.000Z", 
          updated_at: "2023-03-15T00:00:00.000Z", 
          order_items_size: 3
        ) do |order|
          FactoryBot.create(
            :order_item, 
            order: order, 
            id: 1, 
            sku: "3001"
          )
          FactoryBot.create(
            :order_item, 
            order: order, 
            id: 2, 
            sku: "3002"
          )
          FactoryBot.create(
            :order_item, 
            order: order, 
            id: 3, 
            sku: "3003"
          )
        end

        FactoryBot.create(
          :order, 
          id: 2, 
          tracking_number: "100-2002", 
          ship_status: "label_generated", 
          created_at: "2023-03-16T00:00:00.000Z", 
          updated_at: "2023-03-16T00:00:00.000Z", 
          order_items_size: 1, 
        ) do |order|
          FactoryBot.create(
            :order_item, 
            id: 4, 
            order_id: 2, 
            sku: "3004"
          )
        end

        FactoryBot.create(
          :order, 
          id: 3, 
          tracking_number: "100-2003", 
          ship_status: "unship", 
          order_items_size: 1, 
          created_at: "2023-03-17T00:00:00.000Z", 
          updated_at: "2023-03-17T00:00:00.000Z"
        ) do |order|
          FactoryBot.create(
            :order_item, 
            order: order, 
            id: 5, 
            sku: "3005"
          )
        end
      }

      let(:order1) {
        order = FactoryBot.attributes_for(
          :order, 
          id: 1, 
          tracking_number: "100-2001", 
          ship_status: "unship", 
          created_at: "2023-03-15T00:00:00.000Z", 
          updated_at: "2023-03-15T00:00:00.000Z", 
          order_items_size: 3
        )

        order[:directlink_info] = JSON.parse(order[:directlink_info])
        order[:order_items] = [
          FactoryBot.attributes_for(
            :order_item, 
            id: 1, 
            order_id: 1, 
            sku: "3001"
          ), 
          FactoryBot.attributes_for(
            :order_item, 
            id: 2, 
            order_id: 1, 
            sku: "3002"
          ), 
          FactoryBot.attributes_for(
            :order_item, 
            id: 3, 
            order_id: 1, 
            sku: "3003"
          )
        ]

        order
      }

      let(:order1_sku3003) {
        order = FactoryBot.attributes_for(
          :order, 
          id: 1, 
          tracking_number: "100-2001", 
          ship_status: "unship", 
          created_at: "2023-03-15T00:00:00.000Z", 
          updated_at: "2023-03-15T00:00:00.000Z", 
          order_items_size: 3
        )

        order[:directlink_info] = JSON.parse(order[:directlink_info])
        order[:order_items] = [
          FactoryBot.attributes_for(
            :order_item, 
            id: 3, 
            order_id: 1, 
            sku: "3003"
          )
        ]

        order
      }

      let(:order2) {
        order = FactoryBot.attributes_for(
          :order, 
          id: 2, 
          tracking_number: "100-2002", 
          ship_status: "label_generated", 
          order_items_size: 1, 
          created_at: "2023-03-16T00:00:00.000Z", 
          updated_at: "2023-03-16T00:00:00.000Z"
        )

        order[:directlink_info] = JSON.parse(order[:directlink_info])
        order[:order_items] = [
          FactoryBot.attributes_for(
            :order_item, 
            id: 4, 
            order_id: 2, 
            sku: "3004"
          )
        ]

        order
      }

      let(:order3) {
        order = FactoryBot.attributes_for(
          :order, 
          id: 3, 
          tracking_number: "100-2003", 
          ship_status: "unship", 
          order_items_size: 1, 
          created_at: "2023-03-17T00:00:00.000Z", 
          updated_at: "2023-03-17T00:00:00.000Z"
        )

        order[:directlink_info] = JSON.parse(order[:directlink_info])
        order[:order_items] = [
          FactoryBot.attributes_for(
            :order_item, 
            id: 5, 
            order_id: 3, 
            sku: "3005"
          )
        ]

        order
      }

      let(:empty_orders_response) {
        {
          status: "Success", 
          message: "", 
          orders: []
        }
      }
  
      context "when params[:tracking_number] is provided" do
        it "should returns only orders with matching tracking_number" do
          expected_response = {
            status: "Success", 
            message: "", 
            orders: [order3]
          }

          get "/orders", params: {tracking_number: "100-2003"}
          expect(response.status).to eq(200)
          expect(response.body).to eq(expected_response.to_json)
        end
      end
      context "when params[:ship_status] is provided" do
        it "should returns only orders with matching ship_status" do
          expected_response = {
            status: "Success", 
            message: "", 
            orders: [order2]
          }

          get "/orders", params: {ship_status: "label_generated"}
          expect(response.status).to eq(200)
          expect(response.body).to eq(expected_response.to_json)
        end
      end
      context "when params[:sku] is provided" do
        it "should returns only order_items with matching sku" do
          expected_response = {
            status: "Success", 
            message: "", 
            orders: [order1_sku3003]
          }

          get "/orders", params: {sku: "3003"}
          expect(response.status).to eq(200)
          expect(response.body).to eq(expected_response.to_json)
        end
      end
      context "when params[:tracking_number, :ship_status, :sku] provided and matching orders found" do
        it "should return only matching orders/order_items" do
          expected_response = {
            status: "Success", 
            message: "", 
            orders: [order3]
          }

          get "/orders", params: {tracking_number: "100-2003", ship_status: "unship", sku: "3005"}
          expect(response.status).to eq(200)
          expect(response.body).to eq(expected_response.to_json)
        end
      end
      context "when params[:created_at_from] or params[:created_at_to] provided" do
        context "when params[:created_at_from, :created_at_to] are invalid" do
          context "when params[:created_at_from] not provided" do
            it "should return bad request" do
              get "/orders", params: {created_at_to: "2023-03-16 23:59:59"}
              expect(response.status).to eq(400)
            end
          end
          context "when params[:created_at_to] not provided" do
            it "should return bad request" do
              get "/orders", params: {created_at_from: "2023-03-15 00:00:00"}
              expect(response.status).to eq(400)
            end
          end
          context "when params[:created_at_from] is not a valid datetime" do
            it "should return bad request" do
              get "/orders", params: {created_at_from: "abcd"}
              expect(response.status).to eq(400)
            end
          end
          context "when params[:created_at_to] is not a valid datetime" do
            it "should return bad request" do
              get "/orders", params: {created_at_to: "abcd"}
              expect(response.status).to eq(400)
            end
          end
          context "when params[:created_at_to] is less than params[:created_at_from]" do
            it "should return bad request" do
              get "/orders", params: {created_at_from: "2023-03-15 00:00:00", created_at_to: "2023-03-10 00:00:00"}
              expect(response.status).to eq(400)
            end
          end
        end
        context "when params[:created_at_from, :created_at_to] are valid" do
          it "should return matching orders" do
            expected_response = {
              status: "Success", 
              message: "", 
              orders: [order1, order2]
            }

            get "/orders", params: {created_at_from: "2023-03-15 00:00:00", created_at_to: "2023-03-16 23:59:59"}
            expect(response.status).to eq(200)
            expect(response.body).to eq(expected_response.to_json)
          end
        end
      end
      context "when params[:page, :limit] is missing" do
        it "should returns all saved orders" do
          get "/orders"
          expect(response.status).to eq(200)
          response_body_hash = JSON.parse(response.body)
          expect(response_body_hash["orders"].count).to eq(3)
        end
      end
      context "when params[:page] is not integer" do
        it "should return bad request" do
          get "/orders", params: {page: "abc"}
          expect(response.status).to eq(400)
        end
      end
      context "when params[:page] is less than 0" do
        it "should reutrn bad request" do
          get "/orders", params: {page: "-1"}
          expect(response.status).to eq(400)
        end
      end
      context "when params[:page] is valid" do
        it "should returns empty orders when there are 3 saved orders and params[:page] = 1" do
          get "/orders", params: {page: "1"}
          expect(response.status).to eq(200)
          response_body_hash = JSON.parse(response.body)
          expect(response_body_hash["orders"]).to eq([])
        end
      end
      context "when params[:limit] is not integer" do
        it "should return bad request" do
          get "/orders", params: {limit: "abc"}
          expect(response.status).to eq(400)
        end
      end
      context "when params[:limit] is <= 0" do
        it "should return bad request" do
          get "/orders", params: {limit: "0"}
          expect(response.status).to eq(400)
        end
      end
      context "when params[:limit] is valid" do
        it "should returns not more than 2 when there are 3 saved orders and params[:limit] = 2" do
          get "/orders", params: {limit: "2"}
          expect(response.status).to eq(200)
          response_body_hash = JSON.parse(response.body)
          expect(response_body_hash["orders"].count).to be <= 2
        end
      end
      context "when no matching orders found" do
        it "should return success with empty orders" do
          get "/orders", params: {tracking_number: "100-2001", ship_status: "unship", sku: "3005"}
          expect(response.status).to eq(200)
          expect(response.body).to eq(empty_orders_response.to_json)
        end
      end
    end
  end
end
