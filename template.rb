require "fileutils"

source_path = File.expand_path(File.dirname(__FILE__))

# Copy scaffold templates
FileUtils.mkdir_p("lib/templates/erb/scaffold")
FileUtils.cp_r "#{source_path}/lib/templates/erb/scaffold/.", "lib/templates/erb/scaffold"

# Copy layouts
FileUtils.mkdir_p("app/views/layouts")
FileUtils.cp_r "#{source_path}/app/views/layouts/.", "app/views/layouts"

# Add gems
gem "image_processing", ">= 1.2"

after_bundle do
  generate "authentication"
  rails_command "active_storage:install"
  generate "scaffold foobar name:string"
  rails_command "db:migrate"

  # Seed user
  rails_command %(runner "User.create!(email_address: 'test@test.com', password: 'test123')")
end
gsub_file "app/controllers/application_controller.rb",
          "class ApplicationController < ActionController::Base",
          "class ApplicationController < ActionController::Base\n  layout \"admin\""
