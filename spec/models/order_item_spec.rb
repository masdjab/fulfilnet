require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "#valid?" do
    subject {tested_object.valid?}
    let(:tested_object) {OrderItem.new(params)}
    let!(:order) {FactoryBot.create(:order)}

    context "OrderItem.new" do
      let(:default_params) {
        {
          order: order, 
          quantity: "1", 
          sku: "1001001", 
          selling_price: "20.5", 
          selling_price_currency: 1, 
          weight: "1.5", 
          description: "some description", 
          country_alpha2: "some country"
        }
      }

      context "should be valid when all attributes are valid" do
        let(:params) {default_params}
        it {is_expected.to eq(true)}
      end
      context "should not be valid when quantity is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:quantity)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when sku is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:sku)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:selling_price)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price_currency is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:selling_price_currency)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when weight is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:weight)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when description is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:description)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when country_alpha2 is missing" do
        let(:params) {
          req_params = default_params.clone
          req_params.delete(:country_alpha2)
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when quantity is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:quantity] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when quantity is not an integer" do
        let(:params) {
          req_params = default_params.clone
          req_params[:quantity] = "2.0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when quantity is less than 1" do
        let(:params) {
          req_params = default_params.clone
          req_params[:quantity] = "0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price is less than 0" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price] = "-0.5"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price_currency is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price_currency] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price_currency is not an integer" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price_currency] = "1.0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price_currency is less than 1" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price_currency] = "0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when selling_price_currency is greater than 2" do
        let(:params) {
          req_params = default_params.clone
          req_params[:selling_price_currency] = "3"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when weight is not a valid number" do
        let(:params) {
          req_params = default_params.clone
          req_params[:weight] = "some text"
          req_params
        }

        it {is_expected.to eq(false)}
      end
      context "should not be valid when weight is less than 0" do
        let(:params) {
          req_params = default_params.clone
          req_params[:weight] = "-1.0"
          req_params
        }

        it {is_expected.to eq(false)}
      end
    end
  end
end
