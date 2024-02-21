class AddShipmentItemsCountToShipments < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :shipment_items_count, :integer
  end
end
