module Displayable
  extend ActiveSupport::Concern
  
  # Default implementation for displaying an object in forms and listings
  def display_attr
    return self.name if respond_to?(:name)
    return self.title if respond_to?(:title)
    return self.label if respond_to?(:label)
    return self.to_s if self.to_s != "#{self.class.name}##{self.id}"
    
    "#{self.class.name} ##{self.id}"
  end
end