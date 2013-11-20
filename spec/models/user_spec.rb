require 'spec_helper'

describe User do
  it { should be_a(User) }
  it { should be_timestamped_document }
  
  ### CALLBACKS ###
  pending "Callbacks" do
    describe "Before Save" do
      it "" do
      end
    end
  end

  ### RELATIONSHIPS ###
  describe "Relationships" do
    it{should have_many(:debts).of_type(Debt).as_inverse_of(:institution) }
    it{should have_many(:preferred_equities).of_type(PreferredEquity).as_inverse_of(:institution) }
    it{should have_many(:equities).of_type(Equity).as_inverse_of(:institution) }
    it{should have_many(:options).of_type(Option).as_inverse_of(:institution) }
  end	
  
  ### FIELDS ###  
  describe "Fields" do
    it { should have_field(:slug).of_type(String) }
    it { should have_field(:names).of_type(Array) }
    it { should have_field(:desc).of_type(String) }
    it { should have_field(:jottings).of_type(String) }
  end
  
  ### VALIDATIONS ###
  describe "Validations" do
    it { should validate_presence_of(:names) }
  end
    
  ### INSTANCE METHODS ###




end
