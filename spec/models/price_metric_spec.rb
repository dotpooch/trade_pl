require 'spec_helper'

describe PriceMetric do
  it { PriceMetric.new.should be_a(PriceMetric) }

  ### FIELDS ###  
  it { should have_field(:n).of_type(String) }#.with_alias(:name) }
  it { should have_field(:ty).of_type(String) }#.with_alias(:security_type) }
  it { should have_field(:ti).of_type(String) }#.with_alias(:security_type) }
  it { should have_field(:cu).of_type(String) }#.with_alias(:cusip) }
  it { should have_field(:sd).of_type(Date) }#.with_alias(:start_date) }
  it { should have_field(:ed).of_type(Date) }#.with_alias(:end_date) }
  it { should have_field(:c).of_type(Integer) }#.with_alias(:prices_count) }
  
  ### VALIDATIONS ###
  it { should validate_presence_of(:n).on(:create) }
  #it { should validate_presence_of(:ty).on(:create) }
  it { should validate_presence_of(:sd).on(:create) }
  it { should validate_presence_of(:ed).on(:create) }
  it { should validate_presence_of(:c) }
  it { should validate_numericality_of(:c).greater_than(0) }

  ### CLASS METHODS ###

  describe ".update" do
=begin
    subject {Price}
    
    context "PriceMetric needs updating" do

      it "gets Price.all (only name)" do
        subject.stub_chain(:where,:distinct,:sort).and_return([])
        PriceMetric.update.should == ['name1']
      end
    end

    context "Price and PriceMetric relationship" do
 
      it {PriceMetric.update.should == [] }

      it "gets Price.all (only name)" do
        subject.stub_chain(:where,:distinct,:sort).and_return(['name1'])
        PriceMetric.update.should == ['name1']
      end
    end
=end

  end 


  describe ".update_to_date?" do
    subject {PriceMetric.send(:up_to_date?)}

    context "True" do
      it "returns empty Array" do
        Price.stub_chain(:where,:distinct,:sort).and_return([])
        subject.should == []
      end
    end

    context "False" do
      it "returns Array of Security Names to Update" do
        Price.stub_chain(:where,:distinct,:sort) {['name1']}
        subject.should == ['name1']
      end
    end

  end
  
  describe ".find_or_create" do
    subject {PriceMetric.send(:find_or_create, "company_name")}

    it "find or initialize PriceMetric" do
      Price.stub_chain(:where,:distinct,:sort) {['name1']}
      subject.should == ['name1']
    end

    metric = PriceMetric.find_or_initialize_by(:security_name => name)
    metric.prices_count.nil? ? metric.prices_count = price_count(name) : metric.prices_count += price_count(name)
    metric.start_date    = oldest_date(name)
    metric.end_date      = newest_date(name)
    metric.save
  end
  
  describe ".oldest_date" do
    subject {PriceMetric.send(:oldest_date, "company_name")}

    it "calls .get_price_date with 'company_name' and ':asc'" do
      PriceMetric.should_receive(:get_price_date).with("company_name", :asc)
      subject
    end

  end

  describe ".newest_date" do
    subject {PriceMetric.send(:newest_date, "company_name")}

    it "calls .get_price_date with 'company_name' and ':desc'" do
      PriceMetric.should_receive(:get_price_date).with("company_name", :desc)
      subject
    end

  end

  
  describe ".price_count" do
    subject {PriceMetric.send(:price_count, "company_name")}
    let(:mongoid) { mock_model(Mongoid::Criteria).as_null_object }

    it "gets count of new prices"  do
      Price.should_receive(:where).with(n: "company_name", price_metrics: nil) {@mongoid}
      @mongoid.should_receive(:count) {Integer}
      subject
    end
  
  end
  
  describe ".get_price_date" do
    subject {PriceMetric.send(:get_price_date, "company_name", :asc)}
    let(:mongoid) { mock_model(Mongoid::Criteria).as_null_object }
    let(:date)    { Date.new(2011,12,15) }

    it "queries Price.name" do
      Price.stub(:only).with(:d) {@mongoid}
      @mongoid.should_receive(:where).with(n: "company_name", price_metrics: nil) {@mongoid}
      @mongoid.stub_chain(:order_by,:limit,:first,:date) {@date}
      subject
    end

    it "returns Price.date" do
      Price.stub_chain(:only,:where,:order_by,:limit,:first) {Price}
      Price.stub(:date) {@date}
      subject.should == @date
    end

    it "gets newest Price"  do
      Price.should_receive(:only).with(:d) {@mongoid}
      @mongoid.should_receive(:where).with(n: "company_name", price_metrics: nil) {@mongoid}
      @mongoid.should_receive(:order_by).with([:d, :desc]) {@mongoid}
      @mongoid.should_receive(:limit).with(1) {@mongoid}
      @mongoid.should_receive(:first) {Price}
      Price.stub(:date) {@date}
      PriceMetric.send(:get_price_date, "company_name", :desc)
    end

    it "gets oldest Price"  do
      Price.should_receive(:only).with(:d) {@mongoid}
      @mongoid.should_receive(:where).with(n: "company_name", price_metrics: nil) {@mongoid}
      @mongoid.should_receive(:order_by).with([:d, :asc]) {@mongoid}
      @mongoid.should_receive(:limit).with(1) {@mongoid}
      @mongoid.should_receive(:first) {Price}
      Price.stub(:date) {@date}
      subject
    end
    
  end


=begin
  describe ".update_price_metrics" do

    subject {PriceMetric.send(:update_price_metrics)}
    it { subject.should_be == true }

  end


  describe ".price_count_for_security" do
    it "returns Integer" do
      Price.stub_chain(:where,:count,:to_i).and_return(1)
      PriceMetric.send(:price_count_for_security, "company_name").should == 1
    end

  end


=end


=begin

    let(:friend) { stub_model(User) }

    before(:each) do
      User.stub(where: User, fields: User, all: User)
      friend.stub(interested_employers: ["Apple"])
      friend.stub(fb_connections: ["100", "200"])
      friend.stub(fb_user_id: "1")        
      user.stub(fb_connections: ["101", "201"])
      user.stub(fb_user_id: "2")
    end

      a.fb_matches_for_friend_employer_goals(user, friend)


      it "returns empty Array" do
        Price.stub_chain(:where,:distinct,:sort).and_return([])
        subject
 PriceMetric.send(:up_to_date?)        
      end
    end

    context "False" do
      it "returns Array of Security Names to Update" do
        Price.stub_chain(:where,:distinct,:sort).and_return(['name1'])
        subject.should == ['name1']
      end
    end

  end 
=end

end

=begin
  before :each do
    @ticker = "TKR"
    @price =  Price.new(
      :date   => '2012/1/1/',
      :ticker => @ticker,
      :name   => 'Test Name, Ltd.',
      :open   => 10,
      :high   => 10,
      :low    => 10,
      :close  => 10
    )
  end


#If your test isn't conceptually saying "Given input X, my result should always be Y" then you're probably testing the wrong thing. As always, there are exceptions to this rule, but I wouldn't break the rule without a very good reason.

  # =>  #instance_method, => .class_method

    
    @data  = Price.stub('equities').and_return([@hash])
    subject { @price }
    it { should respond_to :name   }
=end

# 
#

=begin
  it "is valid with valid attributes" do
    @price.should be_valid
  end

  it "is not valid without a date" do
    @price.date = nil
    @price.should_not be_valid
  end

  it "is not valid without a ticker" do
    @price.ticker = nil
    @price.should_not be_valid
  end

  it "is not valid without a lowercase ticker" do
    @price.valid?
    @price.ticker.should == @ticker.downcase
  end

  it "is not valid without a name" do
    @price.name = nil
    @price.should_not be_valid
  end

  it "is not valid without an open price" do
    @price.open = nil
    @price.should_not be_valid
  end

  it "is not valid without a high price" do
    @price.high = nil
    @price.should_not be_valid
  end

  it "is not valid without a low price" do
    @price.low = nil
    @price.should_not be_valid
  end

  it "is not valid without a closing price" do
    @price.close = nil
    @price.should_not be_valid
  end
=end

