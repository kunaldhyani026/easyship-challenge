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
    order_clause = determine_order_clause(items_order)
    grouped_items = shipment_items.group(:description).select('description, COUNT(*) as count')
    grouped_items = grouped_items.order("count #{order_clause}") if order_clause.present?
    grouped_items.map { |item| { description: item.description, count: item.count } }
  end

  private

  # Determines the order clause based on the items_order parameter.
  # Parameters:
  # - items_order: A string indicating the order of sorting ('ascending' or 'descending').
  # Returns: A string representing the order clause ('ASC' or 'DESC') or an empty string if no sorting is needed.
  def determine_order_clause(items_order)
    return 'ASC' if items_order == 'ascending'
    return 'DESC' if items_order == 'descending'

    ''
  end
end
