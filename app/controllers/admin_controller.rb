class AdminController < ApplicationController  
  
  before_filter :authorize_admin
  
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def reported_comments
    @comments = Comment.all_reported
    respond_to do |format|
      format.html # reported_comments.html.erb
    end
  end
  
  def authorize_admin
    unless admin?
      redirect_to dashboard_ads_path, notice: I18n.t('access_denied')
      false
    end
  end
  
  def admin?
    return false unless session[:user_id]
    user = User.find(session[:user_id])
    return user.admin
  end
end