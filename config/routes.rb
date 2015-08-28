require 'sidekiq/web'
require 'sidekiq-status/web'

Rails.application.routes.draw do
  authenticate :user do
    get "profile/edit"   => "users#edit",  as: :edit_profile
    put "profile/edit"   => "users#update"
    patch "profile/edit" => "users#update"
  end

  devise_for(
    :users,
    skip: [:sessions, :registrations],
    controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  )

  as :user do
    get 'login'     => 'devise/sessions#new',        as: :new_user_session
    get 'logout'    => 'devise/sessions#destroy',    as: :logout_path
    get 'register'  => 'users/registrations#new',    as: :new_user_registration
    post 'login'    => 'devise/sessions#create',     as: :user_session
    post 'register' => 'users/registrations#create', as: :user_registration
    delete 'logout' => 'devise/sessions#destroy',    as: :destroy_user_session
  end

  # devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/monitor'
  end

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  root to: "products#index"
  # root to: 'high_voltage/pages#show', id: 'home'

  resources :products, only: [:index, :show, :create], concerns: :paginatable do
    collection do
      post 'create/status' => 'products#status', defaults: { format: :json }, constraints: { format: :json }
      post 'create/check' => 'products#parseable', defaults: { format: :json }, constraints: { format: :json }
      post 'search', as: :search_or_add
    end
    member do
      get 'go' => 'products#visit', as: :visit
      post 'like', defaults: { format: :js }, constraints: { format: :js }
    end

    resources :comments, only: [:new, :create]
  end

  get '/:username' => 'users#show', as: :profile
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
