require 'rails_helper'
require 'spec_helper'

RSpec.describe WorksiteTrackerController, :type => :controller do


	before do |example|
	  org = FactoryGirl.create :legacy_organization 
	  @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, admin: false) 
	end

	describe "Get #index" do
		
		context 'invalid token' do
			it "renders the errors - not found view" do
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
				@print_token = PrintToken.create(legacy_site_id: @legacy_site.id)
				@print_token.token_expiration = DateTime.now.prev_day(15)
				@print_token.save!
			end
			it "renders the errors - not found view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get(:index, token: @print_token.token)
				expect(should).to render_template 'errors/not_found'
				expect(response).to have_http_status(404)			
			end	
		end		
		
		context 'valid token' do
			before do |example3|
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
	
	describe "POST #submit" do
		
		context 'token provided' do
			
			before do |example3|
				data = {
					status_notes: 'testnote'
				}
				@legacy_site = FactoryGirl.create(:legacy_site, data: data)
				@print_token = PrintToken.create(token_expiration: DateTime.now.next_day(2), legacy_site_id: @legacy_site.id)
			end		
			
			it "shows not_found error page if no status provided" do
				allow(controller).to receive(:current_user).and_return(@user)
				post :submit, :token => @print_token.token
				expect(should).to render_template 'errors/not_found'
			end		
			
			it "basic submit renders thanks page" do
				allow(controller).to receive(:current_user).and_return(@user)
				exp_email = "test@example.com" 
				exp_org_name = 'testname'
				exp_status_notes = 'testnote'
				post :submit, :token => @print_token.token, 
					:status => "Open, unassigned",
					:num_volunteers => 10,
					:volunteer_hours => 20,
					:email => exp_email,
					:organization_name => exp_org_name,
					:status_notes => exp_status_notes
				expect(should).to render_template :thanks
				
				ls = Legacy::LegacySite.first
				expect(ls.data["total_volunteers"]).to eq("10")
				expect(ls.data["hours_worked_per_volunteer"]).to eq("20")
				
				exp_note = "#{exp_status_notes}\nREPORTED BY: #{exp_email}\nREPORTED BY ORGANIZATION: #{exp_org_name}"
				expect(ls.data["status_notes"]).to include(exp_status_notes)
				
				token = PrintToken.find_by_id(@print_token.id)
				expect(token.reporting_email).to eq(exp_email)
				expect(token.reporting_org_name).to eq(exp_org_name)
			end
		end
		
		context 'legacy site for token does not exist' do
			
			before do |example3|
				@print_token = PrintToken.create(token_expiration: DateTime.now.next_day(2), legacy_site_id: 2)
			end		
			
			it "show server_error page" do
				allow(controller).to receive(:current_user).and_return(@user)
				post :submit, :token => @print_token.token, :status => "Open, unassigned"
				expect(should).to render_template 'errors/server_error'
			end
		end		
		
		context 'invalid token' do
			it "renders the errors - not found view" do
				allow(controller).to receive(:current_user).and_return(@user)
				get(:submit, token: '123456')
				expect(should).to render_template 'errors/server_error'
				expect(response).to have_http_status(500)
			end	
		end		
	end

end