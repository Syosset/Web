module Syosset
  module Integrations
    class Spagett
      include IntegrationProvider

      def initialize(opts = {})
        raise 'Host must be provided.' unless opts&.key?(:host)

        @connection = Faraday.new(url: opts[:host])
      end

      def self.fa_icon
        'question-circle-o'
      end

      def self.options
        {
          host: {
            type: String,
            required: true
          }
        }
      end

      def describe
        @connection.get('/status').body
      rescue StandardError
        'Unable to fetch status. Possibly offline?'
      end

      def on_support_thread(params)
        thread = MessageThread.find(params[:thread_id])
        @connection.post '/threads', id: thread.id.to_s, user_name: thread.user.name
      end

      def on_support_message(params)
        message = Message.find(params[:message_id])
        @connection.post "/threads/#{message.message_thread.id}/messages", message.to_json
      end
    end
  end
end
