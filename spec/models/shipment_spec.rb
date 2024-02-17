require "rails_helper"

RSpec.describe Shipment, type: :model do
  # write your tests here
  describe '#determine_items_ordering' do
    let(:shipment) { Shipment.new }

    it "returns 'ASC' for 'ascending' items_order" do
      result = shipment.send(:determine_items_ordering, 'ascending')
      expect(result).to eq('count ASC')
    end

    it "returns 'DESC' for 'descending' items_order" do
      result = shipment.send(:determine_items_ordering, 'descending')
      expect(result).to eq('count DESC')
    end

    it "returns 'ASC' for case-insensitive 'ascending' items_order" do
      result = shipment.send(:determine_items_ordering, 'ASCENDING')
      expect(result).to eq('count ASC')
    end

    it "returns 'DESC' for case-insensitive 'descending' items_order" do
      result = shipment.send(:determine_items_ordering, 'DESCENDING')
      expect(result).to eq('count DESC')
    end

    it "returns 'ASC' for leading-trailing spaces case-insensitive 'ascending' items_order" do
      result = shipment.send(:determine_items_ordering, '   AScENdinG   ')
      expect(result).to eq('count ASC')
    end

    it "returns 'DESC' for leading-trailing spaces case-insensitive 'descending' items_order" do
      result = shipment.send(:determine_items_ordering, '  DeSceNDiNG ')
      expect(result).to eq('count DESC')
    end

    it 'returns an empty string for any other items_order' do
      result = shipment.send(:determine_items_ordering, 'random_order')
      expect(result).to eq('')
    end

    it 'returns an empty string for nil items_order' do
      result = shipment.send(:determine_items_ordering, nil)
      expect(result).to eq('')
    end

    it 'returns an empty string for empty string items_order' do
      result = shipment.send(:determine_items_ordering, '')
      expect(result).to eq('')
    end

    it 'returns an empty string for numeric items_order' do
      result = shipment.send(:determine_items_ordering, 123)
      expect(result).to eq('')
    end
  end

  describe '#group_shipment_items' do
    let(:shipment) { create(:shipment) }

    it 'groups shipment items by description and returns an array of hashes' do
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'iPad')
      create(:shipment_item, shipment: shipment, description: 'iPhone')

      result = shipment.group_shipment_items('ascending')

      expect(result).to eq([
                             { description: 'Apple Watch', count: 1 },
                             { description: 'iPad', count: 1 },
                             { description: 'iPhone', count: 2 }
                           ])
    end

    it 'returns an empty array if there are no shipment items' do
      result = shipment.group_shipment_items('ascending')

      expect(result).to eq([])
    end

    it 'handles sorting in ascending order' do
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iPad')
      create(:shipment_item, shipment: shipment, description: 'Charger')

      result = shipment.group_shipment_items(' aSCendIng ')

      expect(result).to eq([
                             { description: 'Charger', count: 1 },
                             { description: 'iPad', count: 1 },
                             { description: 'iPhone', count: 2 },
                             { description: 'Apple Watch', count: 3 }
                           ])
    end

    it 'handles sorting in descending order' do
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iPad')
      create(:shipment_item, shipment: shipment, description: 'Charger')

      result = shipment.group_shipment_items('  DESCENDING  ')

      expect(result).to eq([
                             { description: 'Apple Watch', count: 3 },
                             { description: 'iPhone', count: 2 },
                             { description: 'iPad', count: 1 },
                             { description: 'Charger', count: 1 }
                           ])
    end

    it 'handles special characters in descriptions' do
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'iP@d')
      create(:shipment_item, shipment: shipment, description: 'iP@d')

      result = shipment.group_shipment_items('ascending')

      expect(result).to eq([
                             { description: 'Apple Watch', count: 1 },
                             { description: 'iP@d', count: 2 }
                           ])
    end

    it 'handles empty string, only spaces and null in descriptions' do
      create(:shipment_item, shipment: shipment, description: ' ')
      create(:shipment_item, shipment: shipment, description: ' ')
      create(:shipment_item, shipment: shipment, description: 'iPad')
      create(:shipment_item, shipment: shipment, description: 'Watch ')
      create(:shipment_item, shipment: shipment, description: 'Watch')
      create(:shipment_item, shipment: shipment, description: '   ')
      create(:shipment_item, shipment: shipment, description: '   ')
      create(:shipment_item, shipment: shipment, description: '   ')
      create(:shipment_item, shipment: shipment, description: nil)
      create(:shipment_item, shipment: shipment, description: nil)

      result = shipment.group_shipment_items('ascending')

      expect(result).to eq([
                             { description: 'Watch', count: 1 },
                             { description: 'Watch ', count: 1 },
                             { description: 'iPad', count: 1 },
                             { description: nil, count: 2 },
                             { description: ' ', count: 2 },
                             { description: '   ', count: 3 }
                           ])
    end

    it 'handles invalid order clause gracefully' do
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'Apple Watch')
      create(:shipment_item, shipment: shipment, description: 'Charger')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'iPhone')
      create(:shipment_item, shipment: shipment, description: 'iPhone')

      result = shipment.group_shipment_items('invalid_order')

      expect(result).to eq([
                             { description: 'Apple Watch', count: 2 },
                             { description: 'Charger', count: 1 },
                             { description: 'iPhone', count: 3 }
                           ])
    end
  end
end
