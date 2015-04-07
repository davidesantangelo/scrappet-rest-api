require 'rails_helper'

# bundle exec rspec spec/controllers/api/base_controller_spec.rb
RSpec.describe Api::BaseController, type: :controller, order: :defined do
  let!(:url)  {"http://www.google.com" }

  describe "GET #me" do
  	it "returns the url of the request" do
  	  get 'me', url: url

  	  expect(response).to be_success
  	  response_object = MultiJson.load(response.body)
  	  expect(response_object['url']).to eq(url)
  	end
  end
end