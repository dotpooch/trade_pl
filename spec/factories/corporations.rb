FactoryGirl.define do

  factory :corporation do
    names    ["ABC Corporation"]
	desc      "test description"
	jottings  "test jottings"
	
    factory :corp_with_many_names do
      names    ["ABC Corporation", "XYZ Inc.", "DEF Incorporated"]
    end

    factory :corp_with_associations do
      ignore do
        debts_count               4
        preferred_equities_count  1
        equities_count            2
        options_count             3
      end

      after(:create) do |corp, evaluator|
        FactoryGirl.create_list(:debt,             evaluator.debts_count,              corporation: corp)
        FactoryGirl.create_list(:preferred_equity, evaluator.preferred_equities_count, corporation: corp)
        FactoryGirl.create_list(:equity,           evaluator.equities_count,           corporation: corp)
        FactoryGirl.create_list(:option,           evaluator.options_count,            corporation: corp)
      end
    end
  end
  
  factory :debt do
    corporation
  end
  
  factory :preferred_equity do
    corporation
  end
  
  factory :equity do
    corporation
  end
  
  factory :option do
    corporation
  end
  
end