class Category < ApplicationRecord
  def change
  end
  has_ancestry
  has_many :products
end

