require "quartz_mailer"

Quartz.config do |c|
  c.smtp_enabled = true

  c.smtp_address = "email-smtp.ap-southeast-1.amazonaws.com"
  c.helo_domain = "sys@chivi.app"
  c.smtp_port = 25

  c.username = ENV["SMTP_USERNAME"]? || Amber.settings.smtp.username
  c.password = ENV["SMTP_PASSWORD"]? || Amber.settings.smtp.password

  c.use_authentication = true
  c.use_tls = :starttls
end

require "../../src/webcv/mailers/base_mailer"
require "../../src/webcv/mailers/**"
