class Shipment < ApplicationRecord
  belongs_to :company
  has_many :shipment_items

  # Groups the shipment items by description and returns an array of hashes representing
  # each description along with the count of items with that description. The array is
  # sorted based on the count of items in either ascending or descending order based on items_order param.
  # Parameters:
  # - items_order: A string indicating the order of sorting ('ascending' or 'descending').
  # Returns: An array of hashes, each hash containing the description and count of items.
  def group_shipment_items(items_order)
    sorting = items_order.to_s.strip.downcase
    grouped_items = shipment_items.group_by(&:description).map { |description, items| { description: description, count: items.count } }
    return grouped_items.sort_by { |item| item[:count] } if sorting == 'ascending'
    return grouped_items.sort_by { |item| -item[:count] } if sorting == 'descending'

    grouped_items
  end
end
