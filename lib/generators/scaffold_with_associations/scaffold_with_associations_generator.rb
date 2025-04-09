require 'rails/generators/rails/scaffold/scaffold_generator'

class ScaffoldWithAssociationsGenerator < Rails::Generators::ScaffoldGenerator
  source_root File.expand_path('templates', __dir__)

  class_option :skip_associations, type: :boolean, default: false, desc: "Skip generating associations"

  def handle_associations
    return if options[:skip_associations]

    attributes.each do |attribute|
      if attribute.reference?
        add_has_many_association(attribute)
      end
    end
  end

  private

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
end
