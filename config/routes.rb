require 'api'
Trade_PL::Application.routes.draw do
  
  decimals_in_id   = Global.regex_alpha_num_decimal
  excepted_formats = Global.regex_accepted_formats

  ### MATCHES ###

  match '/'               => 'static#home'
  match '/home'           => 'static#home'
  match '/help'           => 'static#help'
  match '/about'          => 'static#about'
  match '/contact'        => 'static#contact'

  ### RESOURCES ###

  resources :corporations,        :id => decimals_in_id
  resources :prices,              :id => decimals_in_id
  resources :trades,              :id => decimals_in_id
  resources :fill_dates,          :id => decimals_in_id
  resources :transactions,        :id => decimals_in_id
  resources :fills,               :id => decimals_in_id
  resources :profitability,       :id => decimals_in_id

  #match 'profitability/lifetime' => 'profitability#lifetime', :as => 'lifetime_profit' 
  #match 'profitability/annual'   => 'profitability#years',    :as => 'annual_profit'
  #match 'profitability/years'    => 'profitability#years',    :as => 'years_profit'
  #match 'profitability/monthly'  => 'profitability#monthly',  :as => 'monthly_profit'
  #match 'profitability/months'   => 'profitability#months',   :as => 'months_profit'

end
