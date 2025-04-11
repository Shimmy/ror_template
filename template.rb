require "fileutils"

source_path = File.expand_path(File.dirname(__FILE__))

# Copy scaffold templates

# Add gems
gem "image_processing", ">= 1.2"
gem 'ajax-datatables-rails'
gem 'tailwindcss-rails'
gem "tailwindcss-ruby", "3.4.13"
gem 'faker'
after_bundle do
  #system("npm install datatables.net-dt")
  rails_command 'tailwindcss:install'
  run "./bin/importmap pin jquery"
  run "./bin/importmap pin datatables.net"
  generate "authentication"
  # Add custom layout to authentication controllers
  gsub_file "app/controllers/passwords_controller.rb",
            "class PasswordsController < ApplicationController",
            "class PasswordsController < ApplicationController\n  layout \"auth/empty\""
            
  gsub_file "app/controllers/sessions_controller.rb",
            "class SessionsController < ApplicationController",
            "class SessionsController < ApplicationController\n  layout \"auth/empty\""
  
  rails_command "active_storage:install"
  FileUtils.cp_r "#{source_path}/.", "."
  generate "better_scaffold document name:string description:text user:references --force --datatables"
  rails_command "db:migrate"

  # Seed user
  rails_command %(runner "User.create!(email_address: 'test@test.com', password: 'test123')")

  # create a home route
  route "root 'home#index', as: :home"
  route "get 'dashboard' => 'dashboard#index', as: :dashboard"
  rails_command "assets:precompile"
  system("rake db:faker:model[Document,50]")
end
gsub_file "app/controllers/application_controller.rb",
          "class ApplicationController < ActionController::Base",
          "class ApplicationController < ActionController::Base\n  layout \"admin\""
