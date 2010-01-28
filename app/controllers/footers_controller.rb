class FootersController < ApplicationController
  
  layout 'admin', :except => [:show]
  before_filter :login_required, :except => [:show]
  
  # GET /footers
  # GET /footers.xml
  def index
    @footers = Footer.first

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @footers }
    end
  end

  # GET /footers/1
  # GET /footers/1.xml
  def show
    @footer = Footer.first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @footer }
    end
  end

  # GET /footers/new
  # GET /footers/new.xml

  # GET /footers/1/edit
  def edit
    @footer = Footer.first
  end

  # PUT /footers/1
  # PUT /footers/1.xml
  def update
    @footer = Footer.find(params[:id])

    respond_to do |format|
      if @footer.update_attributes(params[:footer])
        flash[:notice] = 'Footer was successfully updated.'
        format.html { redirect_to(@footer) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @footer.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
