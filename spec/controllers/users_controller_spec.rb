require 'spec_helper'

describe UserController do
  render_views

  describe "GET 'new'" do
    it "is successful" do
	  get :new
	  expect(response).to be_success
	end
    it "is titled Join"
	  expect(response).to have_selector("title", :content => "join")
	end
  end	
  
end