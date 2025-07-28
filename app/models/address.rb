# Represents a physical address with validation and formatting capabilities.
#
# This model handles address validation ensuring all required components
# are present and properly formatted. The ZIP code validation ensures
# only numeric values with minimum 5-digit length are accepted.
#
# @example Creating a valid address
#   address = Address.new(
#     street_address: "123 Main St",
#     city: "Austin",
#     state: "TX",
#     zip_code: "78701"
#   )
#   address.valid? #=> true
#
# @example Getting formatted address string
#   address.full_address #=> "123 Main St, Austin, TX 78701"
class Address < ApplicationRecord
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, length: { minimum: 5 }, numericality: { only_integer: true }

  def full_address
    "#{street_address}, #{city}, #{state} #{zip_code}"
  end
end
