require "email"
require "../config"

module MailUtil
  CLIENT = EMail::Client.new(
    EMail::Client::Config.create(
      host: "email-smtp.ap-southeast-1.amazonaws.com", port: 25,
      client_name: "Chivi", helo_domain: "chivi.app",
      tls_verify_mode: :peer, use_tls: :starttls,
      auth: {CV::Config.ses_username, CV::Config.ses_password},
      log: Log.for("email"),
      dns_timeout: 3, connect_timeout: 3, read_timeout: 10, write_timeout: 10,
    )
  )

  def self.send(to target : String, subject : String, message : String)
    send(target) do |email|
      email.subject subject
      email.message message
    end
  end

  def self.send(to target : String, &block)
    email = EMail::Message.new

    email.from "sys@chivi.app", "Chivi"
    email.to target

    yield email

    CLIENT.start { send(email) }
  end
end
