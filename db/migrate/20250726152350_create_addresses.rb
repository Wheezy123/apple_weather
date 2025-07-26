class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :geocoded_at

      t.timestamps
    end
  end
end
