class AtlasesController < ApplicationController

  ATLASES_PER_PAGE = 20

  layout 'admin', :except => [:show]
  before_filter :login_required, :except => [:show]

  before_filter :find_atlas, :only => [:show, :edit, :destroy]
  before_filter :ignore_empty_maplists
  
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors

  def create
    @atlas = Atlas.new(params[:atlas])
    Atlas.transaction do
      @map_lists = @atlas.map_lists.build params[:new_map_lists].values if params[:new_map_lists]
      @atlas.save!
    end
    respond_to do |format|
      flash[:notice] = 'Atlas was successfully created.'
      format.html { redirect_to user_atlases_url(current_user.id) }
      format.xml  { render :xml => @atlas, :status => :created, :location => @atlas }
    end
  end

  def destroy
    respond_to do |format|
      if @atlas.destroy
        flash[:notice] = 'Atlas was successfully destroyed.'        
        format.html { redirect_to atlases_path }
        format.xml  { head :ok }
      else
        flash[:error] = 'Atlas could not be destroyed.'
        format.html { redirect_to @atlas }
        format.xml  { head :unprocessable_entity }
      end
    end
  end

  def index
    if params[:user_id]
      @atlases = User.find(params[:user_id]).atlases.paginate(
        :page => params[:page], :per_page => ATLASES_PER_PAGE,
        :order => 'created_at desc')
    else
      @atlases = Atlas.paginate(
        :page => params[:page], :per_page => ATLASES_PER_PAGE,
        :order => 'created_at desc')
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @atlases }
    end
  end

  def mine
    redirect_to user_atlases_url(current_user.id)
  end

  def edit
  end

  def new
    @atlas = Atlas.new
    @atlas.user = current_user
    respond_to do |format|
      format.html
      format.xml  { render :xml => @atlas }
    end
  end

  def show
    respond_to do |format|
      format.html { render :layout => 'main'}
      format.xml  { render :xml => @atlas }
    end
  end

  def update
    Atlas.transaction do
      @atlas.update_attributes!(params[:atlas])
      if params[:map_list] 
        @atlas.map_lists.update params[:map_list].keys, params[:map_list].values
      end
      if params[:new_map_lists]
        @map_lists = @atlas.map_lists.create params[:new_map_lists].values if params[:new_map_lists]
      end
    end
    respond_to do |format|
      flash[:notice] = 'Atlas was successfully updated.'
      format.html { redirect_to @atlas }
      format.xml  { head :ok }
    end
  end

  private
  
  def ignore_empty_maplists
    if params["new_map_lists"]
      params["new_map_lists"].reject!{|k,v| v.values.reject{|vv| vv.empty?}.empty?}
    end
  end

  def find_atlas
    if params[:id]
      @atlas = Atlas.find(params[:id]) if params[:id]
    else params[:url]
      @atlas = Atlas.find_by_url(params[:url])
    end
    raise ActiveRecord::RecordNotFound, "Atlas not found for params #{params.inspect}" if @atlas.nil?
  end

end