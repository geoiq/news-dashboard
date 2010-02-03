class MainController < ApplicationController
  
  @footer = Footer.first
  
  layout 'centered_content'
  
  def index
    @footer = Footer.first || Footer.new(:description => "Default")
  end
  
  def about
    @footer = Footer.first || Footer.new(:description => "Default")
  end
end
