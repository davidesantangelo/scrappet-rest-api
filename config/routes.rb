Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  namespace :api do
    get '/me', to: 'base#me', defaults: {format: :json}
    get '/scrape', to: 'scrapers#scrape', defaults: { format: :json }

    scope :scrape do 
      get '/title', to: 'scrapers#page_title', defaults: { format: :json }
      get '/description', to: 'scrapers#page_description', defaults: { format: :json }
      get '/links', to: 'scrapers#page_links', defaults: { format: :json }
      get '/images', to: 'scrapers#page_images', defaults: { format: :json }
    end
  end
end
