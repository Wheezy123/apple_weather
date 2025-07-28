class Address < ApplicationRecord

  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, length: { minimum: 5 }, numericality: { only_integer: true }


  def full_address
    "#{street_address}, #{city}, #{state} #{zip_code}"
  end

end
