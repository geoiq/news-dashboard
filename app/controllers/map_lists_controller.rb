class MapListsController < ApplicationController

  before_filter :find_map_list

  MAP_LISTS_PER_PAGE = 20

  def create
    @map_list = MapList.new(params[:map_list])
    respond_to do |format|
      if @map_list.save
        flash[:notice] = 'MapList was successfully created.'
        format.html { redirect_to @map_list }
        format.xml  { render :xml => @map_list, :status => :created, :location => @map_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @map_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @map_list.destroy
        flash[:notice] = 'MapList was successfully destroyed.'        
        format.html { redirect_to map_lists_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'MapList could not be destroyed.'
        format.html { redirect_to @map_list }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    @map_lists = MapList.paginate(:page => params[:page], :per_page => MAP_LISTS_PER_PAGE)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @map_lists }
    end
  end

  def edit
  end

  def new
    @map_list = MapList.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @map_list }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @map_list }
    end
  end

  def update
    respond_to do |format|
      if @map_list.update_attributes(params[:map_list])
        flash[:notice] = 'MapList was successfully updated.'
        format.html { redirect_to @map_list }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @map_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_map_list
    @map_list = MapList.find(params[:id]) if params[:id]
  end

end