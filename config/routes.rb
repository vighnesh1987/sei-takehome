Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'api/v1/blocks_proposed_by_validator', to: 'api#blocks_proposed_by_validator'
  get 'api/v1/number_of_transactions_made', to: 'api#number_of_transactions_made'
end
