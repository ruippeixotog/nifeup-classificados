class AdsController < ApplicationController  
  # GET /ads
  # GET /ads.json
  add_breadcrumb I18n.t('home'), :root_path
  
  def index
    @ads = Ad.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ads }
    end
  end

  # GET /ads/1
  # GET /ads/1.json
  def show
    @ad = Ad.find(params[:id])
    @search_terms = params[:search_terms]

    add_breadcrumb @ad.section.name, url_for({:action => 'dashboard', :section_id => @ad.section_id})

    if @search_terms and not @search_terms.empty?
      add_breadcrumb I18n.t('ad.search_for') + " " + @search_terms, url_for({:action => 'dashboard', :search_terms => @search_terms, :section_id => @section_id})
    end
    
    add_breadcrumb @ad.title, ad_path(@ad)
    
    if session[:user_id]
      @user = User.find(session[:user_id])
      if @rating = @user.evaluations.find_by_ad_id(params[:id])
          @rating
      else
          @rating = Evaluation.new
      end
    end
    
    respond_to do |format|
      format.html
      format.pdf {render :layout =>false}
      format.json { render json: @ad }
    end
  end

  # GET /ads/new
  # GET /ads/new.json
  def new
    @ad = Ad.new
    1.times { @ad.resources.build }

    @user = User.find_by_id(session[:user_id])
    
    respond_to do |format|
      if @user
        format.html # new.html.erb
        format.json { render json: @ad }
      else
        format.html { redirect_to root_path, notice: I18n.t(:access_denied) }
      end
    end
  end

  # GET /ads/1/edit
  def edit
    @user_id = session[:user_id]
    @ad = Ad.find(params[:id])
    
    respond_to do |format|
      if @user_id == nil || @user_id != @ad.user_id
        format.html { redirect_to ad_path(@ad), notice: I18n.t('access_denied') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # POST /ads
  # POST /ads.json
  def create
    @ad = Ad.new(params[:ad])
    @ad.user_id = session[:user_id]
    redirect_to(ads_path, notice: I18n.t('must_be_logged')) unless @ad.user_id
    
    respond_to do |format|
      if @ad.save
        if params[:ad][:thumbnail].blank?
          format.html { redirect_to @ad, notice: 'Ad was successfully created.' }
          format.json { render json: @ad, status: :created, location: @ad }
        else
          format.html { render action: "crop" }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ads/1
  # PUT /ads/1.json
  def update
    @ad = Ad.find(params[:id])

    respond_to do |format|
      if @ad.update_attributes(params[:ad])
        if params[:ad][:thumbnail].blank?
          format.html { redirect_to @ad, notice: 'Ad was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: "crop" }
        end
      else
        format.html { render action: "edit" }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ads/1
  # DELETE /ads/1.json
  def destroy
    @ad = Ad.find(params[:id])
    @ad.destroy

    respond_to do |format|
      format.html { redirect_to ads_url }
      format.json { head :ok }
    end
  end
  
  def dashboard
    @section_id = params[:section_id].to_i
    @section_id = 1 unless @section_id > 0
    @search_terms = params[:search_terms]
    @ads = Ad.search_text_by_section(@section_id, @search_terms, params[:page], session[:user_id])
    @sections = Section.all
    
    @user_id = session[:user_id]
    
    section = Section.find(@section_id)
    add_breadcrumb section.name, url_for({:action => 'dashboard', :section_id => @section_id})
    
    if @search_terms and not @search_terms.empty?
      add_breadcrumb I18n.t('ad.search_for') + " " + @search_terms, url_for({:action => 'dashboard', :search_terms => @search_terms, :section_id => @section_id})
    end
  end
  
  def update_search
    @section_id = params[:section_id].to_i
    @section_id = 1 unless @section_id > 0
    @search_terms = params[:search_terms]
    @ads = Ad.search_text_by_section(@section_id, @search_terms, params[:page], session[:user_id])
    @sections = Section.all
    @user_id = session[:user_id]
    section = Section.find(@section_id)
    
    add_breadcrumb section.name, url_for({:action => 'dashboard', :section_id => @section_id})

    if @search_terms and not @search_terms.empty?
      add_breadcrumb I18n.t('ad.search_for') + " " + @search_terms, url_for({:action => 'dashboard', :search_terms => @search_terms, :section_id => @section_id})
    end

    respond_to do |format|
      format.js
    end
  end

  def mark_fav
    @ad = Ad.find(params[:id])
    user_id = session[:user_id]
    if @ad.mark_favorite!(user_id)
      @notice = I18n.t 'ad.success_mark_fav'
    else
      @notice = I18n.t 'ad.failure_mark_fav'
    end
    
    respond_to do |format|
        format.js
    end
  end
  
  def unmark_fav
    @ad = Ad.find(params[:id])
    user_id = session[:user_id]
    if @ad.unmark_favorite!(user_id)
      @notice = I18n.t 'ad.success_unmark_fav'
    else
      @notice = I18n.t 'ad.failure_unmark_fav'
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def rate
    @ad = Ad.find(params[:id])
    user_id = session[:user_id]
    if @ad.rate!(user_id, params[:rating].to_i)
      @notice = I18n.t 'ad.success_rate'
    else
      @notice = I18n.t 'ad.failure_rate'
    end
        
    respond_to do |format|  
        format.js
    end
  end
  
  def update_section
    @section_id = params[:section_id]
    section = Section.find(@section_id)
    @search_terms = params[:search_terms]
    @ads = Ad.search_text_by_section(@section_id, @search_terms, params[:page], session[:user_id])
    @user_id = session[:user_id]
    
    section = Section.find(@section_id)
    add_breadcrumb section.name, url_for({:action => 'dashboard', :section_id => @section_id})
    
    if @search_terms and not @search_terms.empty?
      add_breadcrumb I18n.t('ad.search_for') + " " + @search_terms, url_for({:action => 'dashboard', :search_terms => @search_terms, :section_id => @section_id})
    end
    
    respond_to do |format|
      format.js
    end
  end
    
  #POST ads/1/close
  def close
    @ad = Ad.find(params[:id])
    
    @ad.close!
    @ad.partner = params[:partner]
    
    respond_to do |format|
      format.html { redirect_to @ad, notice: I18n.t('ad.closed_ok') }
      format.json { head :ok }
      format.js
    end
  end
  
end
