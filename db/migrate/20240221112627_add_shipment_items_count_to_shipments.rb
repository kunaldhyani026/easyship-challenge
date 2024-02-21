class AddShipmentItemsCountToShipments < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :shipment_items_count, :integer, default: 0, null: false
    add_index :shipments, :shipment_items_count
  end
end
