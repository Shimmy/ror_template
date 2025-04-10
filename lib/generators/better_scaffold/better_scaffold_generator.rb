# /home/codah/dev/ror/testo/lib/generators/foobar/foobar_generator.rb
require 'rails/generators/rails/scaffold/scaffold_generator'

class BetterScaffoldGenerator < Rails::Generators::ScaffoldGenerator
  # Define the --datatables option
  class_option :datatables, type: :boolean, default: false, desc: "Use DataTables.js-specific templates"
  class_option :skip_associations, type: :boolean, default: false, desc: "Skip generating associations"

  # Set the default source_root (can be overridden later)
  source_root File.expand_path('templates/base', __dir__)

  # Hook to set the source_root dynamically before any actions
  def initialize(*args)
    super(*args) # Call the parent initialize method
    self.class.source_root(datatables_source_root)
  end

  def handle_associations
    return if options[:skip_associations]

    attributes.each do |attribute|
      if attribute.reference?
        add_has_many_association(attribute)
      end
    end
  end

  def create_datatable_file
    template 'datatable.rb.tt', File.join('app/datatables', "#{file_name}_datatable.rb")
  end


  def generate_stimulus_controller
    # Invoke the Stimulus generator with the pluralized resource name
    invoke "stimulus", [plural_file_name]
    create_datatable_js()
  end

  # Override view file generation
  def copy_view_files
    puts "Using source root for views: #{self.class.source_root}"
    view_files = %w[index edit new show _form partial].map { |name| "#{name}.html.erb.tt" }
    empty_directory "app/views/#{plural_file_name}"
    view_files.each do |file|
      template file, "app/views/#{plural_file_name}/#{file.gsub('.tt', '')}"
    end
  end

  # Debug info
  def info
    puts "Custom scaffold templates are being used from: #{self.class.source_root}"
  end

  private
  def create_datatable_js
    template 'datatable.js.tt', File.join('app/javascript/controllers', "#{plural_file_name}_controller.js")
    template 'datatable.css.tt', File.join('app/assets/stylesheets', "#{plural_file_name}_datatable.css")
  end

  def add_has_many_association(attribute)
    model_name = attribute.name.to_s.camelize
    model_file = File.join('app', 'models', "#{attribute.name}.rb")

    if File.exist?(model_file)
      inject_into_class model_file, model_name do
        "  has_many :#{file_name.pluralize}, dependent: :destroy\n"
      end
    else
      say_status("warning", "Model file #{model_file} not found. Skipping has_many association.", :yellow)
    end
  end

  # Determine the source root based on the --datatables option
  def datatables_source_root
    if options[:datatables]
      File.expand_path('templates/datatables', __dir__)
    else
      File.expand_path('templates/base', __dir__)
    end
  end
end