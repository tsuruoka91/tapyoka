class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.ransackable_attributes(_auth_object = nil)
    # すべての列を検索OKとする
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(_auth_object = nil)
    # すべての関連モデルを検索OKとする
    authorizable_ransackable_associations
  end
end
