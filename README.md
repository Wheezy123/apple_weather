# Weather Forecast Application

A Ruby on Rails application that provides weather forecasts for user-submitted addresses with intelligent caching to optimize API usage.

## Features

- Address input form with validation
- Current weather data retrieval using OpenWeatherMap API
- 5-day extended forecast display with daily high/low temperatures
- 30-minute caching by ZIP code to reduce API calls
- Clear cache indicators showing data freshness
- Responsive Bootstrap-based UI
- Comprehensive test suite

## Technical Requirements

- **Ruby Version**: 3.2.2
- **Rails Version**: 7.1.5+
- **Database**: PostgreSQL
- **Cache Store**: Redis

## Dependencies

### Core Dependencies
- `pg` - PostgreSQL adapter
- `redis` - Redis client for caching
- `httparty` - HTTP client for API requests
- `dotenv-rails` - Environment variable management

### Development & Testing
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test data factories
- `webmock` - HTTP request stubbing
- `shoulda-matchers` - Validation testing helpers

## Setup Instructions

### 1. Clone and Install
```bash
git clone <repository-url>
cd apple_weather
bundle install
```

### 2. Environment Configuration
Copy the example environment file and configure your API keys:
```bash
cp .env.example .env
```

Edit `.env` with your API credentials:
```bash
# Get a free API key from https://openweathermap.org/api OR use the provided API key
OPENWEATHER_API_KEY=your_openweathermap_api_key_here

# Redis configuration
REDIS_URL=redis://localhost:6379/0
```

### 3. Database Setup
```bash
rails db:create
rails db:migrate
```

### 4. Start Redis (macOS with Homebrew)
```bash
brew services start redis
```

### 5. Run the Application
```bash
rails server
```

Visit `http://localhost:3000` to use the application.

## Testing

### Run All Tests
```bash
bundle exec rspec
```

### Run Specific Test Types
```bash
# Model tests only
bundle exec rspec spec/models/

# Controller/integration tests only
bundle exec rspec spec/requests/

# Verbose output
bundle exec rspec --format documentation
```

### Test Coverage
The test suite includes:
- Model validations and business logic
- API integration with mocked responses
- Controller behavior testing
- Caching functionality verification

## Architecture Overview

#### Models
- **Address**: Handles address validation and location data storage
- **WeatherForecast**: Manages current weather and extended forecast data storage with cache expiration logic, includes JSON forecast data parsing methods

#### Services
- **WeatherService**: Encapsulates dual OpenWeatherMap API integration (current weather + 5-day forecast) with error handling and forecast data aggregation

#### Controllers
- **WeatherForecastController**: Orchestrates user input, caching logic, and response rendering

### Design Patterns Implemented

1. **Service Object Pattern**: `WeatherService` extracts API logic from controllers
2. **Factory Pattern**: FactoryBot provides consistent test data generation
3. **Repository Pattern**: ActiveRecord scopes for data access (`fresh`, `for_zip`)
4. **Template Method Pattern**: Shared validation and callback patterns in models

### Caching Strategy

The application implements a multi-layered caching approach:

1. **Database Caching**: Weather forecasts stored with `cached_at` timestamps
2. **Time-based Expiration**: 30-minute TTL automatically invalidates stale data
3. **ZIP Code Keying**: Cache organized by location for efficient retrieval
4. **Cache Indicators**: UI clearly shows data source (fresh API vs. cached)

### Data Flow

1. User submits address form
2. Address model validates location
3. System checks for fresh cached forecast by ZIP code
4. If cache miss: WeatherService fetches both current weather and 5-day forecast from OpenWeatherMap APIs
5. New forecast record stored with current weather data and JSON-encoded extended forecast data
6. UI displays current weather and 5-day forecast cards with appropriate cache indicators

## API Integration

### OpenWeatherMap API
- **Current Weather Endpoint**: `http://api.openweathermap.org/data/2.5/weather`
- **Extended Forecast Endpoint**: `http://api.openweathermap.org/data/2.5/forecast`
- **Units**: Imperial (Fahrenheit)
- **Data Retrieved**:
  - Current temperature, daily high/low, weather description
  - 5-day extended forecast with daily temperature ranges and conditions
  - Forecast data aggregated from 3-hour intervals into daily summaries

### Error Handling
- API failures gracefully handled with user-friendly error messages
- Network timeouts and invalid responses logged for debugging

## Scalability Considerations

### Performance Optimizations
- Database indexing on frequently queried fields (zip_code, cached_at)
- Redis caching reduces external API dependencies
- Efficient ActiveRecord scopes minimize database queries

### Production Readiness
- Environment-specific configuration management
- Comprehensive error logging
- Prepared for horizontal scaling with stateless design
- Cache warming strategies for high-traffic ZIP codes

## Deployment

### Environment Variables (Production)
```bash
RAILS_ENV=production
OPENWEATHER_API_KEY=production_api_key
REDIS_URL=production_redis_url
DATABASE_URL=production_database_url
```

### Production Setup
1. Configure environment variables
2. Run database migrations: `rails db:migrate RAILS_ENV=production`
3. Precompile assets: `rails assets:precompile`
4. Start Redis service
5. Deploy using your preferred platform (Heroku, AWS, etc.)
