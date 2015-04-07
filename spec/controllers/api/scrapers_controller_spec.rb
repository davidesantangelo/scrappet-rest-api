require 'rails_helper'

# bundle exec rspec spec/controllers/api/scrapers_controller_spec.rb
RSpec.describe Api::ScrapersController, type: :controller, order: :defined do
  let!(:url)  {"http://www.google.com" }

  describe "GET #title" do
  	it "returns the title of google.com page" do
  	  get 'page_title', url: url

  	  expect(response).to be_success
  	  response_object = MultiJson.load(response.body)
  	  expect(response_object['title']).to eq('Google')
  	end
  end
end