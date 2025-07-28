class RemoveGeocodingColumnsFromAddresses < ActiveRecord::Migration[7.1]
  def change
    remove_column :addresses, :latitude, :decimal
    remove_column :addresses, :longitude, :decimal
    remove_column :addresses, :geocoded_at, :datetime
  end
end
