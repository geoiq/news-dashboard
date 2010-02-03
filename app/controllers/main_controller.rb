class MainController < ApplicationController
  
  @footer = Footer.first
  
  layout 'centered_content'
  
  def index
    @footer = Footer.first
  end
  
  def about
    @footer = Footer.first
  end
end
