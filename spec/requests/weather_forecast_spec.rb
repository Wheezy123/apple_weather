require 'rails_helper'

RSpec.describe 'WeatherForecasts', type: :request do
  let(:weather_api_url) { 'http://api.openweathermap.org/data/2.5/weather' }
  let(:forecast_api_url) { 'http://api.openweathermap.org/data/2.5/forecast' }

  before do
    stub_request(:get, weather_api_url)
      .with(query: hash_including(zip: '78701'))
      .to_return(
        status: 200,
        body: {
          main: {
            temp: 75.0,
            temp_max: 85.0,
            temp_min: 65.0
          },
          weather: [{ description: 'partly cloudy' }]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, forecast_api_url)
      .with(query: hash_including(zip: '78701'))
      .to_return(
        status: 200,
        body: {
          list: [
            {
              dt: Time.current.to_i,
              main: { temp: 80.0 },
              weather: [{ description: 'sunny' }]
            },
            {
              dt: (Time.current + 1.day).to_i,
              main: { temp: 78.0 },
              weather: [{ description: 'cloudy' }]
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  let(:root_path_url) { root_path }
  let(:weather_forecast_path_url) { weather_forecast_index_path }

  describe 'GET /' do
    it 'displays the weather form' do
      get root_path_url
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Weather Forecast')
      expect(response.body).to include('Get Weather')
    end
  end

  describe 'POST /weather_forecast' do
    let(:valid_params) do
      {
        address: {
          street_address: '123 Main St',
          city: 'Austin',
          state: 'TX',
          zip_code: '78701'
        }
      }
    end

    context 'with valid address' do
      it 'creates address and fetches weather' do
        expect do
          post weather_forecast_path_url, params: valid_params
        end.to change(Address, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Weather for 123 Main St, Austin, TX 78701')
        expect(response.body).to include('75°F')
      end

      it 'creates weather forecast record with extended forecast data' do
        expect do
          post weather_forecast_path_url, params: valid_params
        end.to change(WeatherForecast, :count).by(1)

        forecast = WeatherForecast.last
        expect(forecast.zip_code).to eq('78701')
        expect(forecast.current_temperature).to eq(75.0)
        expect(forecast.forecast_data).to be_present
        expect(forecast.extended_forecast).to be_an(Array)
      end
    end

    context 'with cached forecast' do
      let!(:cached_forecast) do
        create(:weather_forecast, :fresh, zip_code: '78701')
      end

      it 'uses cached forecast without API call' do
        post weather_forecast_path_url, params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.body).to include('From cache')
        expect(WeatherForecast.count).to eq(1)
      end
    end

    context 'with invalid address' do
      let(:invalid_params) do
        {
          address: {
            street_address: '',
            city: 'Austin',
            state: 'TX',
            zip_code: '78701'
          }
        }
      end

      it 'does not create address and shows form again' do
        expect do
          post weather_forecast_path_url, params: invalid_params
        end.not_to change(Address, :count)

        expect(response).to have_http_status(:success)
        expect(response.body).to include('Weather Forecast')
        expect(response.body).to include('Get Weather')
      end
    end
  end
end
