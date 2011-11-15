class AdsController < ApplicationController
  # GET /ads
  # GET /ads.json
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
    
    if session[:user_id]
      @user = User.find(session[:user_id])
      if @rating = @user.evaluations.find_by_ad_id(params[:id])
          @rating
      else
          @rating = Evaluation.new
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ad }
    end
  end

  # GET /ads/new
  # GET /ads/new.json
  def new
    @ad = Ad.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ad }
    end
  end

  # GET /ads/1/edit
  def edit
    @ad = Ad.find(params[:id])
  end

  # POST /ads
  # POST /ads.json
  def create
    @ad = Ad.new(params[:ad])

    respond_to do |format|
      if @ad.save
        format.html { redirect_to @ad, notice: 'Ad was successfully created.' }
        format.json { render json: @ad, status: :created, location: @ad }
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
        format.html { redirect_to @ad, notice: 'Ad was successfully updated.' }
        format.json { head :ok }
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
    
    @ads = Ad.search_text_by_section(@section_id, params[:search_terms])
    @sections = Section.all
    
    # (0..5).each { @ads.concat(Ad.all) } # quintiplica os anuncios

    @user_id = session[:user_id]
  end
  
  def update_search
    @section_id = params[:section_id].to_i
    @section_id = 1 unless @section_id > 0
    @ads = Ad.search_text_by_section(@section_id, params[:search_terms])
    @sections = Section.all
    @user_id = session[:user_id]

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
    @section_id = params[:id]
    section = Section.find(@section_id)
    @ads = Ad.order_by_relevance(section.ads.opened)
    @user_id = session[:user_id]
    
    respond_to do |format|
      format.js
    end
  end
  
end
