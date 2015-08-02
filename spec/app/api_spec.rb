require "spec_helper"
require "./app/api"

RSpec.describe Api do
  def app
    Api # this defines the active application for this test
  end

  it "test" do
    get "/categories/1/apps/2"

    expect(last_response.body).to eq("")
    expect(last_response.status).to eq 200
  end
end