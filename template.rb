require "fileutils"

source_path = File.expand_path(File.dirname(__FILE__))

# Copy scaffold templates
FileUtils.mkdir_p("lib/templates/erb/scaffold")
FileUtils.cp_r "#{source_path}/lib/templates/erb/scaffold/.", "lib/templates/erb/scaffold"

FileUtils.mkdir_p("app/models/concerns")
FileUtils.cp_r "#{source_path}/app/models/concerns/.", "app/models/concerns"

FileUtils.mkdir_p("app/helpers")
FileUtils.cp_r "#{source_path}/app/helpers/.", "app/helpers"

# Copy layouts
FileUtils.mkdir_p("app/views/layouts")
FileUtils.cp_r "#{source_path}/app/views/layouts/.", "app/views/layouts"

# Custom generator
FileUtils.mkdir_p("lib/generators/scaffold_with_associations")
FileUtils.cp_r "#{source_path}/lib/generators/scaffold_with_associations/.", "lib/generators/scaffold_with_associations"

# Datatables changes
FileUtils.mkdir_p("lib/templates/rails/scaffold_controller/")
FileUtils.cp_r "#{source_path}/lib/templates/rails/scaffold_controller/.", "lib/templates/rails/scaffold_controller/"


# Nomina rules
FileUtils.cp("#{source_path}/nomina-rules.txt", "nomina-rules.txt")


# Add gems
gem "image_processing", ">= 1.2"
gem 'ajax-datatables-rails'
after_bundle do
  system("npm install datatables.net-dt")
  generate "authentication"
  rails_command "active_storage:install"
  generate "scaffold_with_associations document name:string description:text user:references"
  rails_command "db:migrate"

  # Seed user
  rails_command %(runner "User.create!(email_address: 'test@test.com', password: 'test123')")

  # create a home route
  generate "controller home"

end
gsub_file "app/controllers/application_controller.rb",
          "class ApplicationController < ActionController::Base",
          "class ApplicationController < ActionController::Base\n  layout \"admin\""
