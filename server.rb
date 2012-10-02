require 'sinatra'
require './web_magic'
require './picture'
require './review'
require 'open-uri'
require 'json'
require 'pp'

enable :sessions


def get_post(id)
"https://alpha-api.app.net/stream/0/posts/#{id}?include_annotations=1&access_token=#{session[:auth]}"
end

def get_replies(id)
"https://alpha-api.app.net/stream/0/posts/#{id}/replies?include_annotations=1&include_machine=1&access_token=#{session[:auth]}"
end

get "/callback" do
  magic = WebMagic.new
  data = magic.post("https://alpha.app.net/oauth/access_token",
    {client_id: "phEGhv9wPDAxdKRzX4crcaKDgVLbDMAa",
    client_secret: "E7v3PCT5NQj5Ykcb44h9MKLDYaZdKTT8",
    grant_type: "authorization_code",
    redirect_uri: "http://localhost:9393/callback",
    code: request.params["code"]})
    #pp request.params["code"]
    #pp data
    pp "Response data from app.net: #{data.body}"
    response = JSON.parse(data.body) 
    session[:auth] = response["access_token"] if response["access_token"]
    session[:username] = response["username"] if response["username"]
    #pp data.body
    redirect "/"
end

get "/" do
  pp session[:auth]
  pp request.host_with_port
  erb :main
end

get "/auth" do
  redirect "https://alpha.app.net/oauth/authenticate?client_id=phEGhv9wPDAxdKRzX4crcaKDgVLbDMAa&response_type=code&redirect_uri=http://#{request.host_with_port}/callback&scope=write_post"
end

before do
  pp "Requesting url: #{request.path_info}"
  redirect "/auth" unless session[:auth] || ["/auth","/callback"].any?{|r| r == request.path_info }
end

get "/create/picture" do
  picture = Picture.new(image_url: request.params["image_url"], caption: request.params["caption"])
  data = picture.save
  id = JSON.parse(data.body)["id"]
  magic = WebMagic.new
  redirect "/picture/#{id}"
end


get "/create/review" do
  review = Review.new(comment: request.params["comment"], rating: request.params["rating"], reply_to: request.params["reply_to"])
  data = review.save
  id = JSON.parse(data.body)["id"]
  redirect "/picture/#{request.params["reply_to"]}"
end
  

get "/picture/:id" do
  @post_data = JSON.parse(open(get_post(params[:id])).read)
  @reply_data = JSON.parse(open(get_replies(params[:id])).read)
  @picture_data = @post_data["annotations"].first["value"]
  @poster = @post_data["user"]["name"]
  @id = params[:id]
  erb :picture
end
  
