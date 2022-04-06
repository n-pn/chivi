require "quartz_mailer"

class CV::BaseMailer < Quartz::Composer
  def sender
    address name: "Chivi", email: "sys@chivi.app"
  end
end
