require 'rails_helper'
require 'spec_helper'

RSpec.describe Admin::UsersController, :type => :controller do

  before do |example|
    org = FactoryGirl.create :legacy_organization
    @admin = User.create(name:'Frank', email:'Frank@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin: true)
    @user = User.create(name:'Gary', email:'Gary@aol.com', password:'blue32blue32', legacy_organization_id: org.id, accepted_terms: true, admin: false)
  end

  describe "Get #index" do
    context "with an admin user" do
      it "renders the index view" do
        allow(controller).to receive(:current_user).and_return(@admin)
        get :index
        expect(should).to render_template :index
      end

      it "populates an array of Users" do
        allow(controller).to receive(:current_user).and_return(@admin)
        get :index
        assigns(:users).should eq([@admin, @user])
      end
    end

    context "without an admin user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :index
        expect(should).to redirect_to "/dashboard"
      end
    end

    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        get :index
        expect(should).to redirect_to "/login"
      end
    end
  end

  describe "Get #new" do
    context "with an admin user" do
      it "renders the new view" do
        allow(controller).to receive(:current_user).and_return(@admin)
        get :new
        expect(should).to render_template :new
      end

      it "returns a new user" do
        allow(controller).to receive(:current_user).and_return(@admin)
        get :new
        assigns(:user).name.should eq("")
      end
    end

    context "without an admin user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(@user)
        get :new
        expect(should).to redirect_to "/dashboard"
      end
    end

    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        get :new
        expect(should).to redirect_to "/login"
      end
    end

  end

  describe "Post #create" do
    context "with an admin user" do
      it "creates a new user" do
        allow(controller).to receive(:current_user).and_return(@admin)
        expect {
          post :create, user: FactoryGirl.attributes_for(:user)
        }.to change(User, :count).by(1)
      end

      it "redirects to the user index" do
        allow(controller).to receive(:current_user).and_return(@admin)
        post :create, user: FactoryGirl.attributes_for(:user)
        response.should redirect_to :admin_users
      end
    end

    context "without an admin user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(@user)
        post :create
        expect(should).to redirect_to "/dashboard"
      end
    end

    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        post :create
        expect(should).to redirect_to "/login"
      end
    end
  end

  describe "Get #edit" do
    context "with an admin user" do
      it "renders the edit view with the correct user" do
        allow(controller).to receive(:current_user).and_return(@admin)
        user = FactoryGirl.create :user
        get :edit, id: user
        expect(should).to render_template :edit
      end

      it "assigns the requested user to @user" do
        allow(controller).to receive(:current_user).and_return(@admin)
        user = FactoryGirl.create :user
        get :edit, id: user
        expect(should).to render_template :edit
      end
    end

    context "with current_user" do
      context "edit current_user" do
        it "renders the edit view with the current_user" do
          allow(controller).to receive(:current_user).and_return(@user)
          get :edit, id: @user
          expect(should).to render_template :edit
        end
      end

      context "without an admin user" do
        it "redirects to login" do
          allow(controller).to receive(:current_user).and_return(@user)
          user = FactoryGirl.create :user
          get :edit, id: user
          expect(should).to redirect_to "/dashboard"
        end
      end

      context "without a user" do
        it "redirects to login" do
          allow(controller).to receive(:current_user).and_return(nil)
          user = FactoryGirl.create :user
          get :edit, id: user
          expect(should).to redirect_to "/login"
        end
      end
    end
  end
  describe "Put #update" do
    context "with an admin user" do
      it "locates the correct user" do
        allow(controller).to receive(:current_user).and_return(@admin)
        user = FactoryGirl.create :user
        put :update, id: user, user: FactoryGirl.attributes_for(:user)
            assigns(:user).should eq(user)  
      end
      context "with correct attributes" do
        it "changes the user's attributes" do
          @user = FactoryGirl.create :user
          allow(controller).to receive(:current_user).and_return(@admin)
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, name: "ZZ")
          @user.reload
          @user.name.should eq("ZZ")
        end

        it "redirects the updated user" do
          @user = FactoryGirl.create :user
          allow(controller).to receive(:current_user).and_return(@admin)
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, case_label: "ZZ")
          expect(response).to redirect_to "/admin/users"
        end
      end
    end
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
            put :update, id: @user, user: FactoryGirl.attributes_for(:user, name: "ZZ")
            @user.reload
            @user.name.should eq("ZZ")
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


    context "without an admin user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(@user)
        user = FactoryGirl.create :user
        put :update, id: user
        expect(should).to redirect_to "/dashboard"
      end
    end

    context "without a user" do
      it "redirects to login" do
        allow(controller).to receive(:current_user).and_return(nil)
        user = FactoryGirl.create :user
        post :create, id: user
        expect(should).to redirect_to "/login"
      end
    end
  end

end
