require 'httpclient'
require 'oauthclient'
class WebMagic
  def initialize(options={})
    if options[:oauth]
      #TODO refactor this
    else
      @client = HTTPClient.new
    end
    @max = options[:max] || 8
  end
  
  def get_data(urls)
    @responses = []
    urls.each_slice(@max).map do |url_list|
      url_list.map do |url| 
        [url, @client.get_async(url)]
      end.map do |url,conn|
        begin
        response = conn.pop
        @responses << [url, response]
        rescue SocketError
           @responses << [url,  nil]
        end
      end
    end
    @responses
  end
  
  def post_data(url, body, headers)
    @client.post(url, body, headers)
  end
  
  def post(url,body)
    @client.post(url,body)
  end
end
