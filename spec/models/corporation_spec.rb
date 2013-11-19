require 'spec_helper'

describe Corporation do
  it { should be_a(Corporation) }
  it { should be_timestamped_document }
  
  ### CALLBACKS ###
  pending "Callbacks" do
    describe "Before Save" do
      it "makes slug" do
        @corp = FactoryGirl.build(:corporation)
        expect(@corp).to receive(:make_slug)
		@corp.save
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
  pending "Validations" do
    it { should validate_presence_of(:names) }
  end
    
  ### INSTANCE METHODS ###
  describe "Instance Methods" do
	describe "public" do
      
	  describe "#name" do
	    before(:each) do
		  @corp = FactoryGirl.create(:corporation)
		end
	  
	    it "returns String" do
		  expect(@corp.name).to be_a(String)
		end
	    it "returns current name" do
		  expect(@corp.name).to eq @corp.names.last
		end
	  end

	  describe "#old_names" do
  	    it "returns Array" do
		  @corp = FactoryGirl.create(:corporation)
		  expect(@corp.old_names).to be_an(Array)
		end

        context "when no previously used names" do
          it "is empty" do
		    @corp = FactoryGirl.create(:corporation)
		    expect(@corp.old_names).to be_empty
		  end
		end

		context "when 1 or more previously used names" do
  	      before(:each) do
		    @multi_corp = FactoryGirl.create(:corp_with_many_names)
		  end
		  
  	      it "returns Array" do
		    expect(@multi_corp.old_names).to be_an(Array)
		  end
  	      it "returns all old names" do
		    expect(@multi_corp.old_names).to eq @multi_corp.names[0...-1].reverse
		  end
	      it "is ordered from newest to oldest" do
		    expect(@multi_corp.old_names).to eq @multi_corp.names[0...-1].reverse
		  end
          it "does not return the current name" do
		    expect(@multi_corp.old_names).to_not include(@multi_corp.names.last)
		  end
		end
		 
	  end

	  pending "#make_slug" do
	    before(:each) do
          @corp = FactoryGirl.create(:corporation)
		end

  	    it "creates pretty url slug" do
		  expect(@corp.slug).to eq Slug.make(@corp)
		end
  	    it "is not nil" do
		  expect(@corp.slug).to_not be_nil
		end
	  end

	  describe "#securities" do
	    before(:each) do
		  @corp = FactoryGirl.create(:corp_with_associations)
		end
	  
	    it "returns an Array" do
		  expect(@corp.securities).to be_an(Array)
		end
  	    it "includes 'equities'" do
		  expect(@corp.securities).to include("equities")
	    end
  	    it "includes 'options'" do
		  expect(@corp.securities).to include("options")
	    end
  	    it "includes 'debts'" do
		  expect(@corp.securities).to include("debts")
	    end
  	    it "includes 'preferred_equities'" do
		  expect(@corp.securities).to include("preferred_equities")
	    end
  	    it "is ordered from the largest to smallest # of related securities by class" do
		  expect(@corp.securities).to eq ["debts","options","equities","preferred_equities"]
	    end
	  end
	  
    end
  end
	

=begin
    def create_stubs
    end

    def securities
      relationships = ['equities','options','debts','preferred_equities']
      relationships.sort { |a, b| self.send(b).count <=> self.send(a).count }
    end

    def join
      join_securities
    end

  private
  
  
  
  Hey,

This isn't doing much to test the *behavior* of the object.  Why do
you want to encrypt the password?  Probably so you can authenticate,
right?  I would probably start off with

describe "authenticate" do
  it "finds the user with the given credentials" do
    u = User.create!(:login => "pat", :password => "password")
    User.authenticate("pat", "password").should eq u
  end
end

That might be a bit much to chew at first though.  So you can write
some interim tests that you then throw away.  For example, you might
do

describe User, "when saved" do
  it "should create a salt" do
    u = User.create(:login => "pat", :password => "password")
    u.salt.should_not be_blank
  end

  it "should create a hashed pass" do
    u = User.create(:login => "pat", :password => "password")
    u.hashed_pass.should_not be_blank
  end
end

Once you have those passing, you can move to the User.authenticate
spec.  Once *that* passes, you can throw away the salt/hashed_pass
specs, because they're no longer useful.  They're testing
implementation at this point, and were just a tool to get you where
you wanted to go in small steps.

Pat

  
  
=end


  

  
  
  
  

  ### CLASS METHODS ###

  
  
end

