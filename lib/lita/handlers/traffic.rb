require 'grabz_it'
module Lita
  module Handlers
    class Traffic < Handler

      MESSAGE_REGEX = /traffic me (.+)/i

      route(MESSAGE_REGEX, :generate_map_image,
        help: { "traffic me" => "returns a screenshot of traffic for the city" }
      )

      def generate_map_image(response)
        image = get_image(response)
        response.reply(image)
      end

      def get_image(response)
        message = response.message.body
        city = message.match(MESSAGE_REGEX).captures
        client = GrabzIt::Client.new('NGU5YzE3ZDU5MWVhNDVjOWFmZDliODkzMzU1NmQ0YTQ=', 'VT8/QmxiPz8/P3w/aA4hZD8/LX4DLT9iShw/QT8/Aks=')
        options = {
          :url            => 'http://grabz.it',
          :callback_url   => 'http://example.com/callback',
          :browser_width  => 200,
          :browser_height => 200,
          :output_width   => 200,
          :output_height  => 200,
          :custom_id      => '12345',
          :format         => 'jpg'
        }
        id = client.take_picture(options).screenshot_id
        until (status(id, client) == true)
          sleep(1)
        end
        return client.get_picture(id)
      end

      def status(id, client)
        client.get_status(id)
      end
    end

    Lita.register_handler(Traffic)
  end
end
