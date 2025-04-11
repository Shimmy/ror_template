class DocumentDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      
        name: { source: "Document.name" },
      
        description: { source: "Document.description" },
      
        user: { source: "Document.user" },
      
    }
  end

  def data
    records.map do |record|
      {
        
          name: record.name,
        
          description: record.description,
        
          user: record.user,
        
      }
    end
  end

  def get_raw_records
    Document.all
  end
end
