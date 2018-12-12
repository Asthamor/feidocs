class ApplicationMailer < ActionMailer::Base
  default from: 'feidocs@dsw.com'
  #layout 'mailer'
  def confirmationMail(user)
    @user = user
    mail(to:@user.email, subject: 'Confirmación de cuenta FEIDOCS')
  end
end
