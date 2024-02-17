class Shipment < ApplicationRecord
  belongs_to :companies
  has_many :shipment_items
end
