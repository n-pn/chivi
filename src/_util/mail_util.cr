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

  def self.send(to address : String, subject : String, message : String)
    send(address) do |mail|
      mail.subject subject
      mail.message message
    end
  end

  def self.send(to address : String, name : String?, &block)
    mail = EMail::Message.new

    mail.from "sys@chivi.app", "Chivi"
    mail.to address, name: name

    yield mail

    CLIENT.start { send(email) }
  end
end
