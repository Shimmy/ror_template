module DisplayHelper
  # Returns the most appropriate method to use for displaying a model in select dropdowns
  # If no suitable method is found, returns a lambda that shows a warning message
  def display_method_for(model_class)
    if model_class.method_defined?(:display_attr)
      :display_attr
    elsif model_class.method_defined?(:name)
      :name
    elsif model_class.method_defined?(:title)
      :title
    elsif model_class.method_defined?(:label)
      :label
    elsif model_class.method_defined?(:email_address)
      :email_address  
    elsif model_class.method_defined?(:to_s) && 
          model_class.instance_method(:to_s).owner != Object
      :to_s
    else
      lambda { |model| "Please configure display attribute for model #{model_class.name}" }
    end
  end
end