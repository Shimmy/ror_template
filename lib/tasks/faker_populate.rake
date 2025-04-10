# lib/tasks/faker_populate.rake

namespace :db do
  namespace :faker do
    # Keep your existing 'populate' task as-is
    
    # Add a new task specifically for populating a single model
    desc "Populate a specific model with fake data"
    task :model, [:model_name, :count] => :environment do |t, args|
      model_name = args[:model_name]
      count = (args[:count] || 10).to_i
      
      puts "Starting to populate model: #{model_name}"
      
      # Explicitly load all models
      puts "Loading models..."
      Dir[Rails.root.join('app/models/**/*.rb')].each do |file|
        begin
          require file
        rescue => e
          puts "Error loading #{file}: #{e.message}"
        end
      end
      
      # Generate fake data based on column name and type
      def generate_fake_value(column)
        name = column.name
        type = column.type
        
        # Generate based on column name patterns
        return Faker::Name.name if name.match?(/name/i)
        return Faker::Internet.email if name.match?(/email/i)
        return Faker::Internet.password if name.match?(/password/i)
        return Faker::PhoneNumber.phone_number if name.match?(/phone|mobile/i)
        return Faker::Address.street_address if name.match?(/address/i)
        return Faker::Address.city if name.match?(/city/i)
        return Faker::Address.country if name.match?(/country/i)
        return Faker::Company.name if name.match?(/company/i)
        
        # Generate based on column type
        case type
        when :string
          Faker::Lorem.word
        when :text
          Faker::Lorem.paragraph
        when :integer
          Faker::Number.number(digits: 3)
        when :float, :decimal
          Faker::Number.decimal(l_digits: 2, r_digits: 2)
        when :datetime, :timestamp
          Faker::Time.between(from: 2.years.ago, to: Time.now)
        when :date
          Faker::Date.between(from: 2.years.ago, to: Date.today)
        when :boolean
          [true, false].sample
        else
          nil
        end
      end
      
      # Find the model class
      begin
        model = model_name.classify.constantize
      rescue => e
        puts "Error: Could not find model '#{model_name}'. #{e.message}"
        exit 1
      end
      
      unless model.ancestors.include?(ActiveRecord::Base) && model.table_exists?
        puts "Error: '#{model_name}' is not a valid ActiveRecord model with an existing table."
        exit 1
      end
      
      puts "Populating #{model.name}..."
      
      # Check if this model has required associations
      required_associations = model.reflect_on_all_associations(:belongs_to)
                                   .reject { |a| a.options[:optional] }
      
      if required_associations.any?
        puts "Model has required associations: #{required_associations.map(&:name).join(', ')}"
      end
      
      count.times do
        attributes = {}
        
        # Set attributes including required associations
        model.columns.each do |column|
          # Skip primary key and timestamps
          next if column.name == 'id' || 
                  column.name.in?(%w(created_at updated_at))
          
          if column.name.end_with?('_id')
            association_name = column.name.gsub(/_id$/, '')
            
            if model.reflect_on_association(association_name.to_sym)
              target_class = model.reflect_on_association(association_name.to_sym).klass
              
              if target_class && target_class.count > 0
                attributes[column.name] = target_class.pluck(:id).sample
              else
                puts "Warning: No records found in the #{target_class.name} table for association #{association_name}."
              end
            end
          else
            attributes[column.name] = generate_fake_value(column)
          end
        end
        
        begin
          model.create!(attributes)
          print "."
        rescue => e
          puts "\nFailed to create #{model.name}: #{e.message}"
        end
      end
      
      puts "\nCreated #{count} #{model.name} records."
    end
  end
end
