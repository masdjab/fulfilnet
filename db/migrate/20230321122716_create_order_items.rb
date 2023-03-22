class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.belongs_to :order
      t.integer   :quantity
      t.string    :sku
      t.decimal   :selling_price
      t.integer   :selling_price_currency
      t.decimal   :weight
      t.string    :description
      t.string    :country_alpha2
      t.timestamps
    end
  end
end
