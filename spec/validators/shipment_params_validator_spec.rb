require 'rails_helper'

RSpec.describe ShipmentParamsValidator do
  # write your tests here
  describe '#valid_for_show_action?' do
    context 'method returns true' do
      it 'return true when both id and company_id are valid postive integers' do
        validator = ShipmentParamsValidator.new({ id: 1, company_id: 2 })
        expect(validator.valid_for_show_action?).to eq(true)
      end

      it 'return true when both id and company_id are valid integers in string format' do
        validator = ShipmentParamsValidator.new({ id: '1', company_id: '-2' })
        expect(validator.valid_for_show_action?).to eq(true)
      end

      it 'return true when both id and company_id are valid negative integers' do
        validator = ShipmentParamsValidator.new({ id: -1, company_id: -2 })
        expect(validator.valid_for_show_action?).to eq(true)
      end

      it 'return true when both id and company_id are valid integers' do
        validator = ShipmentParamsValidator.new({ id: -1, company_id: 12 })
        expect(validator.valid_for_show_action?).to eq(true)
      end
    end

    context 'method returns false' do
      it 'return false when either id and company_id have space string character' do
        validator = ShipmentParamsValidator.new({ id: 1, company_id: ' 2' })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when either id and company_id have string character' do
        validator = ShipmentParamsValidator.new({ id: '1bad', company_id: 'invalid' })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when either id and company_id have integer string starting with 0' do
        validator = ShipmentParamsValidator.new({ id: '01', company_id: 2 })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when either id and company_id is float' do
        validator = ShipmentParamsValidator.new({ id: 1, company_id: 2.56 })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when either id and company_id is empty string' do
        validator = ShipmentParamsValidator.new({ id: 1, company_id: '' })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when either id and company_id is string with spaces ' do
        validator = ShipmentParamsValidator.new({ id: 1, company_id: '  ' })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when id is missing ' do
        validator = ShipmentParamsValidator.new({ company_id: 1 })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when company_id is missing ' do
        validator = ShipmentParamsValidator.new({ id: 1 })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when id is nil ' do
        validator = ShipmentParamsValidator.new({ id: nil, company_id: 2 })
        expect(validator.valid_for_show_action?).to eq(false)
      end

      it 'return false when company_id is nil ' do
        validator = ShipmentParamsValidator.new({ id: 12, company_id: nil })
        expect(validator.valid_for_show_action?).to eq(false)
      end
    end
  end
end

