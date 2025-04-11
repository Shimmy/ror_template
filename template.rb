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
  FileUtils.cp_r "#{source_path}/.", "."

  rails_command "active_storage:install"
  generate "better_scaffold document name:string description:text user:references --force --datatables"
  rails_command "db:migrate"
  # Seed user
  rails_command %(runner "User.create!(email_address: 'test@test.com', password: 'test123')")
  # create a home route
  route "root 'home#index', as: :home"
  route "get 'dashboard' => 'dashboard#index', as: :dashboard"
  
  # Create iframe headers config directly with force option
  create_file "config/initializers/iframe_headers.rb", <<~RUBY, force: true
    # Configure headers to allow usage within an iframe
    Rails.application.config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff',
      'X-Download-Options' => 'noopen',
      'X-Permitted-Cross-Domain-Policies' => 'none',
      'Referrer-Policy' => 'strict-origin-when-cross-origin'
    }
  RUBY
  
  # Create or modify Content Security Policy (fixing the 'all' issue)
  create_file "config/initializers/content_security_policy.rb", <<~RUBY, force: true
    # Define a content security policy
    Rails.application.config.content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src    :self, :https, :data
      policy.img_src     :self, :https, :data
      policy.object_src  :none
      policy.script_src  :self, :https
      policy.style_src   :self, :https
      
      # Allow iframe embedding from any source
      policy.frame_ancestors "*"
      
      # Report violations
      # policy.report_uri "/csp-violation-report"
    end
    
    # Generate session nonces for permitted token helpers (see below)
    Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
    Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)
    
    # Report violations without enforcing the policy
    # Rails.application.config.content_security_policy_report_only = true
  RUBY
  
  rails_command "assets:precompile"
  system("rake db:faker:model[Document,50]")
end
gsub_file "app/controllers/application_controller.rb",
          "class ApplicationController < ActionController::Base",
          "class ApplicationController < ActionController::Base\n  layout \"admin\""