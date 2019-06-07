require 'rails_helper'
require 'spec_helper'

RSpec.describe WorksiteTrackerController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		
		context 'invalid token' do
			it "renders the errors not found view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get(:index, token: '123456')
				expect(should).to render_template 'errors/not_found'
				expect(response).to have_http_status(404)
			end	
		end
		
		context 'expired token' do
			before do |example2|
				data = {
					status_notes: 'testnote'
				}
				@legacy_site = FactoryGirl.create(:legacy_site, data: data)
				@print_token = PrintToken.create(token_expiration: DateTime.now.prev_day(2), legacy_site_id: @legacy_site.id)
			end
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get(:index, token: @print_token.token)
				expect(should).to render_template 'errors/not_found'
				expect(response).to have_http_status(404)			
			end	
		end		
		
		context 'valid token' do
			before do |example2|
				data = {
					status_notes: 'testnote'
				}
				@legacy_site = FactoryGirl.create(:legacy_site, data: data)
				@print_token = PrintToken.create(token_expiration: DateTime.now.next_day(2), legacy_site_id: @legacy_site.id)
			end
			it "renders the index view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get(:index, token: @print_token.token)
				expect(should).to render_template :index
			end	
		end	
		
	end

end