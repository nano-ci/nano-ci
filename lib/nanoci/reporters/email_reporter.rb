require 'logging'
require 'mail'

require 'nanoci/reporter'

class Nanoci
  class Reporters
    class EmailReporter < Reporter
      def initialize(config, src = {})
        super(config, src)
        @log = Logging.logger[self]

        @email_config = config.email
        @recipients = src['recipients']
      end

      def send_report(build)
        from = @email_config.from
        subject = "build #{build.tag} failed"
        body = "build #{build.tag} failed"

        @recipients.each do |r|
          begin
            Mail.deliver do
              from    from
              to      r
              subject subject
              body    body
            end
          rescue StandardError => e
            @log.error "failed to send report to #{r}"
            @log.error e
          end
        end
      end
    end
    Reporter.types['email'] = EmailReporter
  end
end
