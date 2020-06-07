Rails.application.routes.draw do
  namespace :slugs do
    get '/origin_url', to: 'slugs#origin_url'
    get '/slugify', to: 'slugs#slugify'
    post '/create', to: 'slugs#create'
    post '/update', to: 'slugs#update'
    get '/api_status', to: 'slugs#api_status'
  end
end
