# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_250_728_203_844) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'addresses', force: :cascade do |t|
    t.string 'street_address'
    t.string 'city'
    t.string 'state'
    t.string 'zip_code'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'weather_forecasts', force: :cascade do |t|
    t.string 'zip_code'
    t.decimal 'current_temperature'
    t.decimal 'high_temperature'
    t.decimal 'low_temperature'
    t.string 'description'
    t.datetime 'cached_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.text 'forecast_data'
  end
end
