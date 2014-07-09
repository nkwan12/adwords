AdwordsOnRails::Application.routes.draw do
  resources :ad_groups


  resources :keywords

	get "/new_generic_ad_group", to: "ad_groups#new_generic_ad_group"
	post "ad_groups/create"
	post "ad_group/add_keys", to: "ad_groups#add_keys"
	post "ad_group/del_key", to: "ad_groups#del_key"
	post "ad_group/make_loc", to: "ad_groups#make_loc"
	post "ad_group/show_keys", to: "ad_groups#show_keys"
	post "ad_group/close_keys", to: "ad_groups#close_keys"
	#get "ad_groups/index"
	
  get "home/index"

  get "campaign/index"
  get "campaign/create"
  post "campaign/new_campaign"
  get "campaign/add_ad_group"
  post "campaign/new_ad_groups"
  post "campaign/new_campaign_and_ads"

  get "budget/index"
  get "budget/create"
  post "budget/new_budget"

  get "account/index"
  get "account/input"
  get "account/select"

  get "login/prompt"
  get "login/callback"
  get "login/logout"

  get "report/index"
  post "report/get"

  root :to => "home#index"
end
