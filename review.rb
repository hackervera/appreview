require './web_magic'
require 'irb'
require 'json'
require 'pp'

class Review
  def initialize(options)
    @magic = WebMagic.new
    @url = "https://alpha-api.app.net/stream/0/posts?include_annotations=1&access_token=#{session[:auth]}"
    
    @body = { reply_to: options[:reply_to], machine_only: true, annotations: [
          {type: "com.pdxbrain.review", value: 
            { comment: options[:comment], rating: options[:rating] } } ] }.to_json
    @header = {"Content-Type"=>"application/json" }
    
  end
  
  def save
    @magic.post_data(@url, @body, @header)
  end
end
