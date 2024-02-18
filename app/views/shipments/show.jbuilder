json.shipment do
  json.extract! @shipment, :company_id, :destination_country, :origin_country, :tracking_number, :slug

  json.created_at @shipment.created_at.strftime('%Y %B %d at %l:%M %p (%A)').gsub('at  ', 'at ')
  json.items @shipment.group_shipment_items('ascending')
end