ActionController::Routing::Routes.draw do |map|
  # Restful Authentication Rewrites
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.register '/register', :controller => 'users', :action => 'new', :conditions => { :method => :get }
  map.account '/account', :controller => 'users', :action => 'edit', :conditions => { :method => :get }
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.find_user '/find_user', :controller => 'users', :action => 'find_user', :conditions => { :method => :get }
  
  # profile routes
  map.profile '/profile', :controller => 'users', :action => 'profile', :conditions => { :method => :get }
  map.profile_update '/profile/update', :controller => 'users', :action => 'profile_update', :conditions => { :method => :put }
  
  # registration routes
  map.team_confirmation '/team_confirmation/:key', :controller => 'team_registrations', :action => 'confirm', :conditions => { :method => :get }
  map.participant_confirmation '/participant_confirmation/:key', :controller => 'participant_registrations', :action => 'confirm', :conditions => { :method => :get }

  # evaluation routes
  map.evaluation_key '/evaluation/:key', :controller => 'evaluations', :action => 'show_from_key', :conditions => { :method => :get }
  
  # tiny mce upload
  map.tinymce_upload 'tinymce/upload', :controller => 'pages', :action => 'tinymce_upload'
  
  map.convio_fail '/convio/fail', :controller => 'payments', :action => 'fail'
  map.convio_success '/convio/success', :controller => 'payments', :action => 'success'
  
  map.connect 'statistics/:name', :controller => 'statistics', :action => 'show'

  # Restful Authentication Resources
  map.resources :users, :member => ['activate_user'], :collection => {:download => :get} do |users|
    users.resources :team_registrations
    users.resources :participant_registrations
    users.resources :equipment_registrations
    users.resources :officials
  end
  map.resources :divisions
  map.resources :districts, :collection => ['num_teams']
  map.resources :regions
  map.resources :passwords
  map.resource :session
  map.resources :participant_registrations,
                :collection => {:add_shared_user => :get,
                                :remove_shared_user => :get,
                                :housing => :get,
                                :filter_housing => :get,
                                :save_housing => :post,
                                :paperwork => :get,
                                :filter_paperwork => :get,
                                :save_paperwork => :post,
                                :ministry_project => :get,
                                :filter_ministry_project => :get,
                                :save_ministry_project => :post,
                                :confirm => :get,
                                :claim => [:get, :post]},
                :member => {:audit => :get}
  map.resources :team_registrations,
                :collection => {:confirm => :get}
  map.resources :equipment_registrations,
                :collection => {:register => :get}
  map.resources :equipment,
                :member => {:save_room => :get,
                            :save_status => :get}
  map.resources :officials,
                :member => {:send_evaluation => :post}
  map.resources :evaluations
  map.resources :seminar_registrations,
                :collection => {:schedule => :get}
  map.resources :registerable_items
  map.resources :pages,
                :collection => {:video => :get, :auditorium => :get}
  map.resources :reports,
                :collection => {:participant_registrations_all => :get,
                                :participant_registrations_complete => :get,
                                :participant_registrations_incomplete => :get,
                                :team_registrations_all => :get,
                                :team_registrations_complete => :get,
                                :team_registrations_incomplete => :get,
                                :coaches_teams => :get,
                                :quizzers_teams => :get,
                                :coaches_quizzers_teams => :get,
                                :group_leaders => :get,
                                :group_leader_summary => [:get, :post],
                                :housing_by_building => [:get, :post],
                                :housing_by_group_leader => [:get, :post],
                                :housing_all => :get,
                                :housing_pre_post => :get,
                                :ministry_projects => [:get, :post],
                                :ministry_projects_full => :get,
                                :equipment_registrations => :get,
                                :seminar_registrations => :get,
                                :participants_liability => :get,
                                :special_needs => :get,
                                :core_staff => :get,
                                :no_team => :get,
                                :housing_meals => :get}
  map.resources :imports
  map.resources :rooms, :collection => {:auto_complete_for_room => :post}
  map.resources :ministry_projects, :collection => {:auto_complete_for_ministry_project_group => :post}
  map.resources :housing_rooms,
                :collection => {:save => :post,
                                :filter => :get,
                                :regenerate => :get}
  map.resources :rounds,
                :member => {:actions => :get},
                :collection => {:recent => :get}
  map.resources :stats,
                :member => {:team => :get,
                            :individual => :get}
  map.resources :teams
  map.resources :payments, :collection => {:receipt => :get}

  # Home Page
  map.root :controller => 'pages', :action => 'home'

  # Install the default routes as the lowest priority.
  #map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
