class ConfigurationsController < ApplicationController
  
  layout 'admin'
  
  def design
    @configuration = Configuration.find :first
    
    if @configuration.nil?
      @configuration = Configuration.new
      @configuration.save!
    end
    
  end
  
  
  def update
    @configuration = Configuration.find params[:id]
    @configuration.update_attributes params[:configuration]
    @configuration.save!
    flash[:notice] = "Your configuration changes were successfully saved."
    redirect_to design_path
  end
  
  
end
