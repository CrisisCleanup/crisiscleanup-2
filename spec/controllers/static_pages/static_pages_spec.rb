require 'rails_helper'
require 'spec_helper'

RSpec.describe StaticPagesController, :type => :controller do
	describe "Get #index" do
		it "renders the index view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :index
			expect(should).to render_template :index
		end
	end

	describe "Get #about" do
		it "renders the about view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :about
			expect(should).to render_template :about
		end
	end

	describe "Get #public_map" do
		it "renders the public_map view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :public_map
			expect(should).to render_template :public_map
		end
	end

	describe "Get #privacy" do
		it "renders the privacy view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :privacy
			expect(should).to render_template :privacy
		end
	end

	describe "Get #terms" do
		it "renders the terms view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :terms
			expect(should).to render_template :terms
		end
	end

	describe "Get #signup" do
		it "renders the signup view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :signup
			expect(should).to render_template :signup
		end
	end

	describe "Get #new_incident" do
		it "renders the new_incident view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :new_incident
			expect(should).to render_template :new_incident
		end
	end

	describe "Get #redeploy" do
		it "renders the redeploy view" do
			allow(controller).to receive(:current_user).and_return(nil)
			get :redeploy
			expect(should).to render_template :redeploy
		end
	end
end