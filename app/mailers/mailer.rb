class Mailer < ActionMailer::Base
  default from: "classificados@fe.up.pt"

  def evaluate_ad(ad)
    @user = ad.partner
    @url  = "http://example.com/login"
    mail(:to => @user.email, :subject => "Welcome to My Awesome Site")
  end
end
