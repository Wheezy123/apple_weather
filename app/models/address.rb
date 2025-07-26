class Address < ApplicationRecord
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.address_changed? && obj.persisted? }
  after_validation :geocode, unless: :persisted?

  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, length: { minimum: 5 }, numericality: { only_integer: true }

  scope :geocoded, -> { where.not(latitude: nil, longitude: nil) }

  def full_address
    "#{street_address}, #{city}, #{state} #{zip_code}"
  end

  def coordinates
    [latitude, longitude] if geocoded?
  end

  def geocoded?
    latitude.present? && longitude.present?
  end

  private

  def address_changed?
    street_address_changed? || city_changed? || state_changed? || zip_code_changed?
  end
end
