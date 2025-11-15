class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_SENDER", "pnmstocktrading@deidei.tech")
  layout "mailer"
end
