require 'rails_helper'
require 'spec_helper'

RSpec.describe UsersController, :type => :controller do

  before do |example|
    org = FactoryGirl.create :legacy_organization
    @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin: true)
    @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin: false)
  end

  describe "Get #edit" do
    context "with current_user" do
      context "edit current_user" do
        it "renders the edit view with the current_user" do
          allow(controller).to receive(:current_user).and_return(@user)
          get :edit, id: @user
          expect(should).to render_template :edit
        end
      end
    end
  end
  describe "Put #update" do
    context "with current_user" do
      context "edit current_user" do
        it "locates the correct user" do
          @user = FactoryGirl.create :user
          allow(controller).to receive(:current_user).and_return(@user)
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, name: "ZZ")
          @user.reload
          @user.name.should eq("ZZ")
        end
        context "with correct attributes" do
          it "changes the user's attributes" do
            @user = FactoryGirl.create :user
            allow(controller).to receive(:current_user).and_return(@user)
            
			put :update, id: @user, user: FactoryGirl.attributes_for(:user, mobile: "555-555-5555")
			@user.reload

			put :update, id: @user, user: FactoryGirl.attributes_for(:user, title: "Mr")
			@user.reload


			put :update, id: @user, user: FactoryGirl.attributes_for(:user, role: "Leader")
			@user.reload


			put :update, id: @user, user: FactoryGirl.attributes_for(:user, name: "Fred")
			@user.reload
			  
            [@user.name, @user.mobile, @user.title, @user.role].should eq(["Fred", "555-555-5555", "Mr", "Leader"])
          end

          it "redirects the updated user" do
            @user = FactoryGirl.create :user
            allow(controller).to receive(:current_user).and_return(@user)
            put :update, id: @user, user: FactoryGirl.attributes_for(:user, case_label: "ZZ")
            expect(response).to redirect_to "/dashboard"
          end
        end
      end
    end
  end
end