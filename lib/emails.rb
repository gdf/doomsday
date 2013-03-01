#!ruby
require 'net/smtp'

def email(body, subject, toList, smtpFrom, smtpServer)
  raise "No email body" unless body and not body.empty?
  raise "No TO list" unless toList and not toList.empty?
  raise "No FROM" unless smtpFrom and not smtpFrom.empty?
  raise "No SMTP server" unless smtpServer and not smtpServer.empty?

  msgstr= <<END_OF_MSG
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: #{smtpFrom}
To: #{toList.join(',')}
Subject: #{subject}

#{body}
END_OF_MSG

  puts "Sending mail to #{toList.join(',')}..."
  Net::SMTP.start(smtpServer) do |smtp|
    smtp.send_message msgstr, smtpFrom, toList
  end 
end
