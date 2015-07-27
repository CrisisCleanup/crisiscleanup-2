class StaticPagesController < ApplicationController
  def index
  end
  def about
      render :layout => 'application_sidebar'
  end
  def public_map
      render :layout => 'application_sidebar'
  end
  def privacy
  end
  def terms
  end      
end
