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
    @ads = Ad.all
    # TODO colocar user da sessão
    @user = User.epinto
    puts "#\n#\n#\n#\n#\n"
    puts @user.inspect
  end
  
  def mark_fav
    @ad = Ad.find(params[:id])
    # TODO logged user
    user_id = User.epinto
    if @ad.mark_favorite(user_id)
      flash[:notice] = 'Ad was successfully marked as favorite.'
    else
      flash[:notice] = 'It was not possibly to mark the ad as favorite.'
    end
    
    render :nothing => true
  end
  
  def unmark_fav
    @ad = Ad.find(params[:id])
    # TODO logged user
    user_id = User.epinto
    if @ad.unmark_favorite(user_id)
      flash[:notice] = 'Ad was successfully unmarked as favorite.'
    else
      flash[:notice] = 'It was not possibly to unmark the ad as favorite.'
    end
    
    render :nothing => true
  end
  
end
