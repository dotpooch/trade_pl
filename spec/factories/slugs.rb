FactoryGirl.define do

  factory :slug do
    app_generated_slugs ["app_generated_slug_1", "app_generated_slug_2", "app_generated_slug_3"]
    user_created_slugs  nil

    factory :user_created_slugs do
      user_created_slugs ["user_create_slug_1", "user_create_slug_2", "user_create_slug_3"]
    end
	
    factory :slug_with_associations do
      ignore do
        #debts_count               4
      end

      after(:create) do |slug, evaluator|
      #  FactoryGirl.create_list(:debt,             evaluator.debts_count,              corporation: corp)
      end
    end
  end
  
end