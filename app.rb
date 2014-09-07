require 'sinatra'
require './image'

post '/shut' do
  content_type :json

  handle = params[:handle]
  image  = Image.new(handle)

  image.create_and_upload unless image.exists?

  {handle: handle, url: image.url}.to_json
end
