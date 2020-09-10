Rails.application.routes.draw do

  devise_for :credit
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions:      'users/sessions',
  }
  devise_scope :user do
    get 'addresses', to: 'users/registrations#new_address'
    post 'addresses', to: 'users/registrations#create_address'
  end

  get 'searches/index'
  root to: 'top#index'
  resources :top, only: [:index, :new]

  resources :products, only: [:index, :new, :create, :edit, :show, :destroy] do
    collection do
      get 'get_category_children', defaults: { fomat: 'json'}
      get 'get_category_grandchildren', defaults: { fomat: 'json'}
    end
  end

  resources :credit_cards, onry: [:new, :create, :destroy, :show] do
    collection do                  #id無
      get 'regist_done'            #登録済
      get 'delete_done'            #削除済
    end
    member do                      #id有
      get 'buy'
      post 'pay'
    end
  end
  
  resources :users, only: [:index, :show]
  resources :images, only: [:index, :new, :create] 
end
