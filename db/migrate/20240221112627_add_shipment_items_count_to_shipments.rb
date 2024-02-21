class AddShipmentItemsCountToShipments < ActiveRecord::Migration[6.1]
  def change
    add_column :shipments, :shipment_items_count, :integer
  end
end
