class ResetAllShipmentCacheCounters < ActiveRecord::Migration[5.0]
  def up
    Shipment.all.each do |shipment|
      Shipment.reset_counters(shipment.id, :shipment_items)
    end
  end

  def down
    # no rollback
  end
end
