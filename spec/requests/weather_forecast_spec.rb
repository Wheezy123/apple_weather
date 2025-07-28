require 'rails_helper'

RSpec.describe "WeatherForecasts", type: :request do
  before do
    stub_request(:get, /api.openweathermap.org/)
      .to_return(
        status: 200,
        body: {
          main: {
            temp: 75.0,
            temp_max: 85.0,
            temp_min: 65.0
          },
          weather: [{ description: "partly cloudy" }]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    stub_request(:get, /nominatim.openstreetmap.org/)
      .to_return(
        status: 200,
        body: [{
          lat: "30.2672",
          lon: "-97.7431"
        }].to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe "GET /" do
    it "displays the weather form" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Weather Forecast")
      expect(response.body).to include("Get Weather")
    end
  end

  describe "POST /weather_forecast" do
    let(:valid_params) do
      {
        address: {
          street_address: "123 Main St",
          city: "Austin",
          state: "TX",
          zip_code: "78701"
        }
      }
    end

    context "with valid address" do
      it "creates address and fetches weather" do
        expect {
          post weather_forecast_index_path, params: valid_params
        }.to change(Address, :count).by(1)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Weather for 123 Main St, Austin, TX 78701")
        expect(response.body).to include("75°F")
      end

      it "creates weather forecast record" do
        expect {
          post weather_forecast_index_path, params: valid_params
        }.to change(WeatherForecast, :count).by(1)
        
        forecast = WeatherForecast.last
        expect(forecast.zip_code).to eq("78701")
        expect(forecast.current_temperature).to eq(75.0)
      end
    end

    context "with cached forecast" do
      let!(:cached_forecast) do
        create(:weather_forecast, :fresh, zip_code: "78701")
      end

      it "uses cached forecast without API call" do
        post weather_forecast_index_path, params: valid_params
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("From cache")
        expect(WeatherForecast.count).to eq(1)
      end
    end

    context "with invalid address" do
      let(:invalid_params) do
        {
          address: {
            street_address: "",
            city: "Austin",
            state: "TX",
            zip_code: "78701"
          }
        }
      end

      it "does not create address and shows form again" do
        expect {
          post weather_forecast_index_path, params: invalid_params
        }.not_to change(Address, :count)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Weather Forecast")
        expect(response.body).to include("Get Weather")
      end
    end
  end
end
