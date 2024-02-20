require 'rails_helper'

RSpec.describe ShipmentParamsValidator do
  # write your tests here

  describe '#validate' do
    context 'when action is show' do
      it 'returns true when both id and company_id are valid postive integers' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 1, company_id: 2 })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid integers in string format' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: '1', company_id: '-2' })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid negative integers' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: -1, company_id: -2 })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid integers' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: -1, company_id: 12 })
        expect(validator.validate).to eq(true)
      end

      it 'returns false when either id and company_id have space string character' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 1, company_id: ' 2' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id have string character' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: '1bad', company_id: 'invalid' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id have integer string starting with 0' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: '01', company_id: 2 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is float' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 1, company_id: 2.56 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is empty string' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 1, company_id: '' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is string with spaces ' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 1, company_id: '  ' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when id is missing ' do
        validator = ShipmentParamsValidator.new({ action: 'show', company_id: 1 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when company_id is missing ' do
        validator = ShipmentParamsValidator.new({ action: 'show',  id: 1 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when id is nil ' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: nil, company_id: 2 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when company_id is nil ' do
        validator = ShipmentParamsValidator.new({ action: 'show', id: 12, company_id: nil })
        expect(validator.validate).to eq(false)
      end
    end

    context 'when action is tracking' do
      it 'returns true when both id and company_id are valid postive integers' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 1, company_id: 2 })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid integers in string format' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: '1', company_id: '-2' })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid negative integers' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: -1, company_id: -2 })
        expect(validator.validate).to eq(true)
      end

      it 'returns true when both id and company_id are valid integers' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: -1, company_id: 12 })
        expect(validator.validate).to eq(true)
      end

      it 'returns false when either id and company_id have space string character' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 1, company_id: ' 2' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id have string character' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: '1bad', company_id: 'invalid' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id have integer string starting with 0' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: '01', company_id: 2 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is float' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 1, company_id: 2.56 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is empty string' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 1, company_id: '' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when either id and company_id is string with spaces ' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 1, company_id: '  ' })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when id is missing ' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', company_id: 1 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when company_id is missing ' do
        validator = ShipmentParamsValidator.new({ action: 'tracking',  id: 1 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when id is nil ' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: nil, company_id: 2 })
        expect(validator.validate).to eq(false)
      end

      it 'returns false when company_id is nil ' do
        validator = ShipmentParamsValidator.new({ action: 'tracking', id: 12, company_id: nil })
        expect(validator.validate).to eq(false)
      end
    end

    context 'when action neither show nor tracking' do
      it 'returns false' do
        validator = ShipmentParamsValidator.new({ action: 'other' })
        expect(validator.validate).to eq(false)
      end
    end
  end

  describe '#integer?' do
    it 'returns true for an integer string value' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, '123')).to eq(true)
    end

    it 'returns true for an positive integer value' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, 123)).to eq(true)
    end

    it 'returns true for an negative integer value' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, -23)).to eq(true)
    end

    it 'returns false for a string value' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, 'abc')).to eq(false)
    end

    it 'returns false for a string integer value but with other string characters' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, '12 abc')).to eq(false)
    end

    it 'returns false for a string integer value with spaces' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, ' 12 ')).to eq(false)
    end

    it 'returns false for a float value' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, 12.5)).to eq(false)
    end

    it 'returns false for a string integer value with leading zeroes' do
      validator = ShipmentParamsValidator.new({})
      expect(validator.send(:integer?, '01')).to eq(false)
    end
  end
end

