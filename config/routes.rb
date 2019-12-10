# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :users
    resources :offices
    resources :age_ranges
    resources :races
    resources :languages
    get 'reports' => 'reports#index'
    get 'reports/total-volunteer-minutes-by-office' => 'reports#total_volunteer_minutes_by_office'
    get 'reports/total-volunteer-minutes-by-state' => 'reports#total_volunteer_minutes_by_state'
    get 'reports/total-volunteer-minutes-by-county' => 'reports#total_volunteer_minutes_by_county'
    get 'reports/total-children-served-by-office' => 'reports#total_children_served_by_office'
    get 'reports/total-children-served-by-state' => 'reports#total_children_served_by_state'
    get 'reports/total-children-served-by-county' => 'reports#total_children_served_by_county'
    get 'reports/total-children-by-demographic' => 'reports#total_children_by_demographic'
    get 'reports/total-volunteers-by-race' => 'reports#total_volunteers_by_race'
    get 'reports/total-volunteer-minutes-by-user' => 'reports#total_volunteer_minutes_by_user'
    get 'reports/total-volunteers-by-spoken-language' => 'reports#total_volunteers_by_spoken_language'

    root to: 'users#index'
  end

  devise_for :users, controllers: {
    invitations: 'invitations'
  }, skip: [:registrations]

  as :user do
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users' => 'devise/registrations#update', as: 'user_registration'
  end

  resources :blockouts, except: %i[index new edit show]
  resources :needs do
    resources :shifts, except: %i[new]
    patch 'mark_unavailable', on: :member
    post 'office_social_workers', on: :collection
  end

  get 'verify' => 'verifications#index', as: :verify
  post 'send_code' => 'verifications#send_code', as: :send_code
  post 'check_code' => 'verifications#check_code', as: :check_code


  root to: 'needs#index'
end
