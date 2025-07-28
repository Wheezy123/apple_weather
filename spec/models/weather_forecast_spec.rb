require 'rails_helper'

RSpec.describe WeatherForecast, type: :model do
  subject(:forecast) { build(:weather_forecast) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:zip_code) }
    it { is_expected.to validate_presence_of(:current_temperature) }
  end

  describe '.cached_forecast_for' do
    let(:zip_code) { '12345' }
    let!(:fresh_forecast) { create(:weather_forecast, :fresh, zip_code: zip_code) }
    let!(:expired_forecast) { create(:weather_forecast, :expired, zip_code: zip_code) }
    let!(:other_zip_forecast) { create(:weather_forecast, :fresh, zip_code: '67890') }

    it 'returns the most recent fresh forecast for the given zip code' do
      expect(WeatherForecast.cached_forecast_for(zip_code)).to eq(fresh_forecast)
    end

    it 'excludes expired forecasts' do
      fresh_forecast.destroy
      expect(WeatherForecast.cached_forecast_for(zip_code)).to be_nil
    end

    it 'excludes forecasts for other zip codes' do
      expect(WeatherForecast.cached_forecast_for('99999')).to be_nil
    end
  end

  describe '#cache_expired?' do
    context 'when cached_at is within 30 minutes' do
      let(:forecast) { build(:weather_forecast, cached_at: 10.minutes.ago) }

      it { expect(forecast.cache_expired?).to be false }
    end

    context 'when cached_at is older than 30 minutes' do
      let(:forecast) { build(:weather_forecast, cached_at: 45.minutes.ago) }

      it { expect(forecast.cache_expired?).to be true }
    end
  end

  describe '#from_cache?' do
    context 'when persisted and not expired' do
      let(:forecast) { create(:weather_forecast, :fresh) }

      it { expect(forecast.from_cache?).to be true }
    end

    context 'when not persisted' do
      let(:forecast) { build(:weather_forecast) }

      it { expect(forecast.from_cache?).to be false }
    end

    context 'when expired' do
      let(:forecast) { create(:weather_forecast, :expired) }

      it { expect(forecast.from_cache?).to be false }
    end
  end

  describe 'scopes' do
    let!(:fresh_forecast) { create(:weather_forecast, :fresh) }
    let!(:expired_forecast) { create(:weather_forecast, :expired) }

    describe '.fresh' do
      it 'returns only fresh forecasts' do
        expect(WeatherForecast.fresh).to contain_exactly(fresh_forecast)
      end
    end

    describe '.for_zip' do
      let(:zip_code) { '12345' }
      let!(:matching_forecast) { create(:weather_forecast, zip_code: zip_code) }

      it 'returns forecasts for the specified zip code' do
        expect(WeatherForecast.for_zip(zip_code)).to contain_exactly(matching_forecast)
      end
    end
  end
end
