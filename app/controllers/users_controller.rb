class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  add_breadcrumb I18n.t('home'), :root_path
  
  def login
  end
  
  def authenticate
    ldap_info = Ldap.auth(params[:person][:username], params[:person][:password])
    
    respond_to do |format|
      if ldap_info
        user = User.find_or_create_by_username(params[:person][:username])
        user.save
        
        if user.blocked_until == nil || user.blocked_until < Time.now
        
            session[:user_id] = user.id
            session[:username] = params[:person][:username]
            
            format.html { redirect_to dashboard_ads_path, notice: I18n.t('login_success') }
            format.json { render json: @ad, status: :created, location: @ad }
        else
            format.html { redirect_to dashboard_ads_path, notice: I18n.t('user.blocked') }
            format.json { render json: @ad.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to dashboard_ads_path, notice: I18n.t('login_failure') }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # logout
  # clears the session
  def logout
    session[:user_id] = nil
    session[:username] = nil
    
    respond_to do |format|
      format.html { redirect_to dashboard_ads_path, notice: I18n.t('logout_success') }
      format.json { render json: @ad, status: :logged_out }
    end
  end
  
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
      format.js
    end
  end

  def auto_complete
    @users = User.find(:all, :conditions => ['username LIKE ?', "#{params[:term]}%"])
    
    @labels = []
    @users.each do |u|
      @labels << {:label => u.username}
    end
    
    respond_to do |format|
      format.json { render json: @labels.to_json }
    end
  end
  
  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
  
  def ads
    add_breadcrumb I18n.t('user.ads'), :ads_users_path
    
    @user = User.find_by_id(session[:user_id])
    respond_to do |format|
      if @user
        @ads = @user.ads.page(params[:page])
        format.html
      else
        format.html { redirect_to root_path, notice: I18n.t(:access_denied) }
      end
    end
  end
  
  def favorites
    add_breadcrumb I18n.t('user.favorites'), :favorites_users_path
    
    @user = User.find_by_id(session[:user_id])
    respond_to do |format|
      if @user
        @ads = @user.favorite_ads.page(params[:page])
        format.html
      else
        format.html { redirect_to root_path, notice: I18n.t(:access_denied) }
      end
    end
  end
  
end
