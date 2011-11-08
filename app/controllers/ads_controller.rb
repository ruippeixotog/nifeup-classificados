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
    @search = Ad.search(params[:search])
    @ads = @search.all
    @sections = Section.all
    
    # (0..5).each { @ads.concat(Ad.all) } # quintiplica os anuncios

    # TODO colocar user da sessão
    @user = User.epinto
  end

  def update_search
    @search = Ad.search(params[:search])
    @ads = @search.all
    @sections = Section.all

    # TODO colocar user da sessão
    @user = User.epinto

    respond_to do |format|
      format.js
    end
  end

  def mark_fav
    # TODO logged user
    @user = User.epinto
    @ad = Ad.find(params[:id])
    if @ad.mark_favorite(@user.id)
      @notice = I18n.t 'ad.success_mark_fav'
    else
      @notice = I18n.t 'ad.failure_mark_fav'
    end
    
    respond_to do |format|
        format.js
    end
  end
  
  def unmark_fav
    # TODO logged user
    @user = User.epinto
    @ad = Ad.find(params[:id])
    if @ad.unmark_favorite(@user.id)
      @notice = I18n.t 'ad.success_unmark_fav'
    else
      @notice = I18n.t 'ad.failure_unmark_fav'
    end
    
    respond_to do |format|
      format.js
    end
  end
  
end
