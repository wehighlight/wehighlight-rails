require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Sessions' do
  header "Accept", "application/vnd.hilitit.v1"

  let!(:user) { create(:user) }

  post "/api/sessions" do
    parameter :email, "Email", :required => true, :scope => :user
    parameter :password, "Password", :required => true, :scope => :user

    let(:email) { user.email }
    let(:password) { user.password }

    example_request "Logging in" do
      hash = JSON.parse(response_body)
      expect(hash['success']).to eql(true)
      expect(hash['user']['email']).to eql(user.email)
      expect(status).to eq 200
    end
  end

  delete "/api/sessions" do
    include Warden::Test::Helpers

    before (:each) do
      login_as user, scope: :user
    end

    example_request "Logging out" do
      hash = JSON.parse(response_body)
      hash.delete('csrfParam')
      hash.delete('csrfToken')

      expect(hash.to_json).to eql({:info => "Logged out",
                                            :success => true
                                           }.to_json)
      expect(status).to eq 200
    end
  end
end



