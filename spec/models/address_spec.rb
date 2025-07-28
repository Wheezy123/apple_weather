require 'rails_helper'

RSpec.describe Address, type: :model do
  subject(:address) { build(:address, attributes) }
  
  let(:valid_attributes) do
    {
      street_address: '123 Main St',
      city: 'Austin',
      state: 'TX',
      zip_code: '78701'
    }
  end
  
  let(:attributes) { valid_attributes }

  describe 'validations' do
    context 'with valid attributes' do
      it { is_expected.to be_valid }
    end

    it { is_expected.to validate_presence_of(:street_address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_length_of(:zip_code).is_at_least(5) }
    it { is_expected.to validate_numericality_of(:zip_code).only_integer }

  end

  describe '#full_address' do
    it 'returns formatted address string' do
      expect(address.full_address).to eq('123 Main St, Austin, TX 78701')
    end
  end

end
