class ProjectDatatable < AjaxDatatablesRails::ActiveRecord
  def view_columns
    @view_columns ||= {
      
        name: { source: "Project.name" },
      
        docker_container_id: { source: "Project.docker_container_id" },
      
        user: { source: "Project.user" },
      
    }
  end

  def data
    records.map do |record|
      {
        
          name: record.name,
        
          docker_container_id: record.docker_container_id,
        
          user: record.user,
        
      }
    end
  end

  def get_raw_records
    Project.all
  end
end
