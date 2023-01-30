Rails.application.routes.draw do
  # get 'relationships/followings'
  # get 'relationships/followers'
  devise_for :admins, skip: [:registrations, :passwords], controllers: {
  sessions: "admin/sessions"
}

  devise_for :users, skip: [:passwords], controllers: {
  registrations: "public/registrations",
  sessions: 'public/sessions',
  passwords: 'users/passwords'
}

  devise_scope :user do
    post 'users/guest_sign_in', to: 'public/sessions#guest_sign_in'
  end

  scope module: :public do
    root to: 'homes#top'
    get "about" => "homes#about"
    get '/users/:id/unsubscribe' => 'users#unsubscribe', as: 'unsubscribe'
    patch '/users/:id/withdrawal' => 'users#withdrawal', as: 'withdrawal'
    get 'users/favorites' => 'users#favorites'
    get 'users/follow' => 'users#follow'
    get 'user/search' => 'users#search'
    get 'post_images/search' => 'post_images#search'
    get 'post_images/favorite' => 'post_images#favorite'

    resources :rooms, only: [:create, :show, :index] do
      resources :messages, only: [:create]
    end
    resources :post_images, only: [:new, :create, :index, :show, :destroy, :edit, :update] do
      resource :favorites, only: [:create, :destroy]
      resources :post_comments, only: [:create, :destroy]
    end
    resources :users, only: [:show, :edit, :update] do


      resource :relationships, only: [:create, :destroy]
      get 'followings' => 'relationships#followings', as: 'followings'
      get 'followers' => 'relationships#followers', as: 'followers'

    end


  end

  namespace :admin do
    get 'homes/top'
    get 'user/search' => 'users#search'
    get 'post_images/search' => 'post_images#search'
    patch '/users/:id/withdrawal' => 'users#withdrawal', as: 'withdrawal'
    resources :users, only: [:index, :show, :edit, :update]
    resources :post_images, only: [:index, :show, :destroy, :edit, :update] do
      resource :favorites, only: [:create, :destroy]
      resources :post_comments, only: [:destroy]
    end
  end


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
