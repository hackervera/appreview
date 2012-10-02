require './web_magic'
require 'irb'
require 'json'
require 'pp'

class Picture
  def initialize(session, options)
    @magic = WebMagic.new
    @url = "https://alpha-api.app.net/stream/0/posts?include_annotations=1&access_token=#{session[:auth]}"
    
    @body = { machine_only: true, annotations: [
          {type: "com.pdxbrain.picture", value: 
            { image: options[:image_url], caption: options[:caption] } } ] }.to_json
    @header = {"Content-Type"=>"application/json" }
    
  end
  
  def save
    @magic.post_data(@url, @body, @header)
  end
end
