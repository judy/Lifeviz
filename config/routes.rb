ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resources :users
  map.resources :species
  
  # AJAX Navigation
  map.taxonomy_dropdown '/taxonomy/dropdown/:rank', 
    :controller => :taxonomy_navigation, 
    :action => :dropdown_options, 
    :rank => /(kingdoms|phylums|classes|orders|families|genuses|species)/,
    :conditions => {:method => :get}
  
  map.root :controller => :species
end
