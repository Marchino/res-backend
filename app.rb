require 'sinatra'
require 'sinatra/flash'
require 'httparty'
require 'json'

enable :sessions

class Review
  include HTTParty
  base_uri 'http://localhost:3000'
  def self.fetch
    response = get '/reviews', format: :plain
    JSON.parse response, symbolize_names: true
  end

  def self.update id, params
    response = put "/reviews/#{id}", body: params, format: :plain
    if response.code == 200
      JSON.parse response, symbolize_names: true
    else
      false
    end
  end
end

helpers do
  def json_to_ruby_time(json_date)
    string_elements = json_date.split /[-T:+]+/
    string_elements.pop
    Time.new *(string_elements.map(&:to_i))
  end
end

get '/' do
  redirect '/reviews'
end

get '/reviews' do
  @reviews = Review.fetch
  erb :index
end

post '/reviews/:id' do
  review = Review.update params[:id], params
  if review
    flash[:success] = 'Action completed succesfully.'
  else
    flash[:danger] = 'We are sorry but something went wrong.'
  end
  redirect '/reviews'
end
