require 'grabz_it'
require 'aws-sdk'
module Lita
  module Handlers
    class Traffic < Handler

      def self.default_config(config)
        config.aws_access_key = nil
        config.aws_secret_key = nil
        config.grabzit_key = nil
        config.grabzit_secret = nil
      end

      MESSAGE_REGEX = /traffic me (.+)/i

      route(MESSAGE_REGEX, :generate_map_image,
        help: { "traffic me" => "returns a screenshot of traffic for the city" }
      )

      def generate_map_image(response)
        image_url = get_image(response)
        response.reply(image_url)
      end

      def get_image(response)
        traffic_bucket = aws_bucket
        message = response.message.body
        city = message.match(MESSAGE_REGEX).captures
        client = GrabzIt::Client.new(GRABZIT_KEY, GRABZIT_SECRET)
        options = {
          :url            => 'https://www.google.ca/maps/@53.5558774,-113.4939486,11z/data=!5m1!1e1',
          :browser_width  => 1024,
          :browser_height => 768,
          :output_width   => 200,
          :output_height  => 200,
          :custom_id      => '12345',
          :format         => 'jpg'
        }
        id = client.take_picture(options).screenshot_id
        image = client.get_picture(id)
        obj = traffic_bucket.objects.create(city.first, image.image_bytes)
        # save image to your local machine
        #image.save("/Users/ruben/Desktop/#{city.first}.jpg")
        return obj.public_url
      end

      # method is giving an error
      def status(id, client)
        client.get_status(id)
      end

      def aws_bucket
        AWS.config(
          :access_key_id => AWS_ACCESS_KEY,
          :secret_access_key => AWS_SECRET_KEY)
        s3 = AWS::S3.new
        s3.buckets['lita-traffic']
      end
    end

    Lita.register_handler(Traffic)
  end
end
