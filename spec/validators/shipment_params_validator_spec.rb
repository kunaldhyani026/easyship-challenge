require 'rails_helper'

RSpec.describe ShipmentParamsValidator do
  # write your tests here
  describe '#valid_for_show_action?' do
    context 'when both id and company_id are present' do
      let(:params) { { id: 1, company_id: 2 } }

      it 'returns true' do
        expect(described_class.new(params).valid_for_show_action?).to be_truthy
      end
    end

    context 'when id is missing' do
      let(:params) { { company_id: 2 } }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when company_id is missing' do
      let(:params) { { id: 1 } }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when both id and company_id are missing' do
      let(:params) { {} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when id is nil' do
      let(:params) { {id: nil, company_id: 2} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when company_id is nil' do
      let(:params) { {id: 1, company_id: nil} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when both id and company_id is nil' do
      let(:params) { {id: nil, company_id: nil} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when id is empty string' do
      let(:params) { {id: '', company_id: 2} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when company_id is empty string' do
      let(:params) { {id: 1, company_id: ''} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when both id and company_id is empty string' do
      let(:params) { {id: '', company_id: ''} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when id is string with only spaces' do
      let(:params) { {id: '   ', company_id: 2} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when company_id is string with only spaces' do
      let(:params) { {id: 12, company_id: '    '} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end

    context 'when both id and company_id is string with only spaces' do
      let(:params) { {id: '   ', company_id: '    '} }

      it 'returns false' do
        expect(described_class.new(params).valid_for_show_action?).to be_falsy
      end
    end
  end
end

