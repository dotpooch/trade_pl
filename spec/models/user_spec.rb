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
    it { should have_field(:email).of_type(String) }
    it { should have_field(:encrypted_password).of_type(String) }
    it { should have_field(:reset_password_token).of_type(String) }
    it { should have_field(:reset_password_sent_at).of_type(Time) }
    it { should have_field(:remember_created_at).of_type(Time) }
    it { should have_field(:sign_in_count).of_type(Integer) }
    it { should have_field(:current_sign_in_at).of_type(Time) }
    it { should have_field(:last_sign_in_at).of_type(Time) }
    it { should have_field(:current_sign_in_ip).of_type(String) }
    it { should have_field(:last_sign_in_ip).of_type(String) }
  end
  
  ### VALIDATIONS ###
  describe "Validations" do
    it { should validate_presence_of(:names) }
  end
    
  ### INSTANCE METHODS ###




end
