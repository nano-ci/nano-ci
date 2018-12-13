require 'mail'

require 'nanoci'
require 'nanoci/mixins/logger'
require 'nanoci/reporter'

module Nanoci
  class Reporters
    class EmailReporter < Reporter
      include Nanoci::Mixins::Logger

      def initialize(src = {})
        super(src)

        @email_config = Nanoci.config.email
        @recipients = src[:recipients]
      end

      def send_report(build)
        from = @email_config.from
        state = Nanoci::Build::State.to_sym(build.state)
        subject = "build #{build.tag} #{state}"
        body = "build #{build.tag} #{state}"

        settings = {
          domain: 'nanoci.net',
          address: @email_config.host,
          port: @email_config.port,
          user_name: @email_config.username,
          password: @email_config.password,
          authentication: 'plain'
        }

        begin
          smtp_conn = Net::SMTP.new(settings[:address], settings[:port])
          smtp_conn.enable_starttls if @email_config.encryption == :starttls
          smtp_conn.enable_tls if @email_config.encryption == :tls
          smtp_conn = smtp_conn.start(settings[:domain],
                                      settings[:user_name],
                                      settings[:password],
                                      settings[:authentication])
        rescue StandardError => e
          log.error "failed to open smtp connection to #{settings[:address]}"
          log.error e
          return
        end

        @recipients.each do |r|
          begin
            log.debug "sending email to #{r}"
            mail = Mail.new do
              from    from
              to      r
              subject subject
              body    body
            end
            mail.delivery_method :smtp_connection, connection: smtp_conn
            mail.deliver
            log.debug "successfully sent email to #{r}"
          rescue StandardError => e
            log.error "failed to send report to #{r}"
            log.error e
          ensure
            smtp_conn.finish
          end
        end
      end
    end
    Reporter.types['email'] = EmailReporter
  end
end
