Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :applications do
    resources :chats do
      resources :messages
    end
  end
end
