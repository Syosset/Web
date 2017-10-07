# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }, skip: [:passwords]
  resources :users, only: [:show] do
    resources :periods, on: :member, except: [:show]
  end
  mount Peek::Railtie => '/peek'


  root 'welcome#index'
  get 'landing' => 'welcome#landing'

  get 'z/index.html', to: redirect("/")

  get 'about' => 'welcome#about'
  get 'day_color', controller: 'day_color', action: 'day_color'
  get 'autocomplete', :to => 'application#autocomplete'

  resources :announcements, only: [:index, :show]
  resources :links, only: [:index]

  resources :activities

  resources :departments, shallow: true do
    member do
      post :subscribe
      post :unsubscribe
    end
    resources :courses do
      member do
        post :subscribe
        post :unsubscribe
      end
    end
  end

  namespace :admin do
    root :to => "base#index"
    post "/toggle" => "base#toggle"

    get "/color" => "color#edit"
    post "/color" => "color#update"
    post "/color_trigger_update" => "color#trigger_update"

    resources :users, only: [:index, :edit, :update]

    post "/rankables/sort" => "rankables#sort", :as => :sort_rankable

    resources :announcements
    resources :links

    resources :activities do
      member do
        post :unlock
      end
    end

    resources :departments, shallow: true, only: [:new, :create, :edit, :update, :destroy] do
      resources :courses
    end

    resources :integrations do
      post :clear_failures, on: :member
    end

    resources :escalation_requests do
      post "approve", action: :approve, as: :approve
      post "deny", action: :deny, as: :deny
    end

    resources :collaborator_groups, only: [:edit, :update] do
      post "add_collaborator", action: :add_collaborator, as: :add_collaborator
      post "remove_collaborator", action: :remove_collaborator, as: :remove_collaborator
    end
  end

  resources :alerts do
    collection do
      post "read_all"
    end
  end
end
