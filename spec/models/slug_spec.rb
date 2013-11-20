require 'spec_helper'

describe Slug do
  it { should be_a(Slug) }
  it { should be_timestamped_document }
  
  ### CALLBACKS ###
  describe "Callbacks" do
    describe "Before Save" do
      it "makes slug" do
        @corp = FactoryGirl.build(:corporation)
        expect(@corp).to receive(:make_slug)
		@corp.save
      end
    end
  end

  ### RELATIONSHIPS ###
  pending "Relationships" do
  #  it{should belong_to(:debt).of_type(Debt).as_inverse_of(:slug) }

  end	
  
  ### FIELDS ###  
  describe "Fields" do
    it { should have_field(:app_generated_slugs).of_type(Array) }
    it { should have_field(:user_created_slugs).of_type(Array) }
  end
  
  ### VALIDATIONS ###
  pending "Validations" do
    it { should validate_presence_of(:app_generated_slugs) }
  end
    
  ### INSTANCE METHODS ###
  describe "Instance Methods" do
	describe "public" do
      
	  describe "#slug" do
	    before(:each) do
		  @slug_obj = FactoryGirl.create(:slug)
		  @slug_phrase = @slug_obj.slug
		end
	  
	    it "returns String" do
		  expect(@slug_phrase).to be_a(String)
		end
	    it "is not nil" do
		  expect(@slug_phrase).to_not be nil
		end

        context "only app generated slugs" do
	      it "returns last app generated" do
		    expect(@slug_phrase).to eq @slug_obj.app_generated_slugs.last
		  end
		end
        context "user created slugs" do
	      it "returns last user created" do
		    @slug_obj = FactoryGirl.create(:user_created_slugs)
		    @slug_phrase = @slug_obj.slug
		    expect(@slug_phrase).to eq @slug_obj.user_created_slugs.last
		  end
		end
	  end
	end
	  
	describe "private" do
	
	  #describe "#build_relationships" do
	  #end
	
	  #describe "#make_association" do
	  #end

	  describe "#db_collections" do
	    before(:each) do
		  slug = Slug.new
		  @collections = slug.send(:db_collections)
		end
	  
	    it "returns Array" do
		  expect(@collections).to be_a(Array)
		end
	  	it "contains file names" do
		  @collections.each do |file|
            expect(file.end_with?(".rb")).to be true
		  end
		end
	    it "read the files in 'app/models/db_collections'" do
		  @collections.each do |file|
            expect(file.start_with?("app/models/db_collections/")).to be true
		  end
		end
	  end

	  #describe "#clean_collection" do
	  #end

	  describe "#clean_filename" do
	    before(:each) do
  		  @slug = Slug.new
		  file = "app/models/db_collections/corporation.rb"
		  @file_name = @slug.send(:clean_filename).with(file)
		end
	  
	    it "takes a String" do
		  expect(@slug).to receive(:clean_filename).with(kind_of(String))
		end
	    it "returns String" do
		  expect(@file_name).to be_a(String)
		end
	  	it "removes file extension" do
          expect(@file_name.end_with?(".rb")).to be false
		end
	  	it "removes file path" do
          expect(@file_name.start_with?("app/models/db_collections")).to be false
		end
     end

=begin

    def build_relationships
	  clean_collection(db_collections).each { |model| make_association(model) }
    end

    def make_association(_model)
	  Slug.belongs_to(_model.to_sym, {:class_name => _model.camelize, :inverse_of => :slug})
	end	
  
    def db_collections
	  # File.basename(Dir.getwd)
	  Dir["app/models/db_collections/*.rb"]
	end

	def clean_collection(_models)
	  _models.map! { |element| clean_filename(element) }
	  _models.delete("slug")
	  _models.delete("stub")
	  _models
	end
	
=end
	  
	  
	end
  end

  ### CLASS METHODS ###
  describe "Class Methods" do
	#describe "public" do
	
	  #describe "#make" do
	    
	  #end
	  
    #end
	
	describe "private" do

	  describe "#obj_slug_method_name" do
	    before(:each) do
		  Slug.stub(:obj_class).and_return("test_class")
		  @output = Slug.send(:obj_slug_method_name)
		end
	  
	    it "returns String" do
		  expect(@output).to be_a String
		end
	    it "appends '_slug' to object class name" do
		  expect(@output).to eq "test_class_slug"
		end
	  end

	  describe "#obj_class" do
	    before(:each) do
		  Slug.instance_variable_set("@obj", Slug.new)
		  @output = Slug.send(:obj_class)
		end
	  
	    it "returns String" do
		  expect(@output).to be_a String
		end
	    it "return Class name" do
		  expect(@output).to eq "slug"
		end
	    it "is lowercase" do
		  expect(@output).to eq @output.downcase
		end
	  end

	  describe "#join" do
	    before(:each) do
		  @slug = Slug.new
		  @corp = Corporation.new
		  Slug.instance_variable_set("@obj", Corporation.new)
		  @output = Slug.send(:join)
		end
	  
	    it "creates belong_to Association" do
		  method = @corp.class.name.downcase
		  expect(@slug.send(method.to_sym)).to eq @obj 
		end
	  end
	  
	  
	  
	end
	
  end
 
end

=begin  

    def stub_exists?(_name)
      Stub.where(:name => _name).exists?
    end

=end

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