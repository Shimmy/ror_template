class DockerManager
  DOCKERFILE_PATH = Rails.root.join('Dockerfile')
  IMAGE_NAME_PREFIX = 'rails_app_project_'
  PORT_RANGE_START = 3000  # Starting port number
  
  def initialize(project)
    @project = project
    @image_name = IMAGE_NAME_PREFIX + project.docker_container_id
    @container_name = "container_#{@image_name}"
    @port = find_available_port
  end
  
  def build_image
    Docker::Image.build_from_dir("/home/codah/ror_template", { t: @image_name })
  end
  
  def create_container
     image = ensure_image_exists
     container = Docker::Container.create(
       'Image' => @image_name, 
       'name' => @container_name,
       'ExposedPorts' => { '3000/tcp' => {} },
       'HostConfig' => {
         'PortBindings' => { '3000/tcp' => [{ 'HostPort' => @port.to_s }] }
       },
       'Cmd' => [
         'bash', 
         '-c', 
         'cd /app/myApp && bundle exec rails server -b 0.0.0.0 || tail -f /dev/null'
       ],
       'Env' => [
         'RAILS_ENV=development',
         'BUNDLE_PATH=/usr/local/bundle'
       ]
     )
     
     # Store both the container ID and the assigned port
     @project.update!(
       docker_container_id: container.id,
       docker_port: @port
     )
     
     container
   end
   
   def container_url
     "http://localhost:#{@port || @project.docker_port}"
   end

  def container_logs
    container = fetch_container
    logs = container.logs(stdout: true, stderr: true)
    p("Container logs: #{logs}")
    logs
  end

  def start_container
    container = fetch_container
    p("STARTING Container #{container.id}")
    container.start
    p("STARTED - Container info: #{container.info['State']}")
    
    # Add this to verify the container is actually running
    running_containers = Docker::Container.all
    p("Currently running containers: #{running_containers.map(&:id)}")
    
    container
  end
  def diagnose_docker_connection
    begin
      info = Docker.info
      p("Connected to Docker daemon: #{info['Name']}")
      p("Docker version: #{info['ServerVersion']}")
      p("Total containers: #{info['Containers']}")
      p("Running containers: #{info['ContainersRunning']}")
    rescue => e
      p("Error connecting to Docker: #{e.message}")
    end
  end
  private
  def find_available_port
      # Use the project's existing port if it has one
      return @project.docker_port if @project.respond_to?(:docker_port) && @project.docker_port.present?
      
      # Otherwise find an available port
      port = PORT_RANGE_START
      max_port = PORT_RANGE_START + 1000  # Set a reasonable upper limit
      
      while port < max_port
        # Check if this port is already in use by another project
        if Project.where(docker_port: port).where.not(id: @project.id).exists?
          port += 1
          next
        end
        
        # Also check if the port is actually free on the host
        begin
          socket = TCPServer.new('127.0.0.1', port)
          socket.close
          return port  # Port is available
        rescue Errno::EADDRINUSE
          port += 1  # Try next port
        end
      end
      
      raise "No available ports found in range #{PORT_RANGE_START}-#{max_port}"
    end
  
  def fetch_container
    # Try to get by ID first (the most reliable way)
    if @project.docker_container_id.present?
      begin
        p("fetch container by id:  #{@project.docker_container_id}")
        return Docker::Container.get(@project.docker_container_id)
      rescue Docker::Error::NotFoundError
        # Container with this ID no longer exists
      p("Container by id not found!")
      end
    end
    
    # Try to get by name
    begin
        p("fetch container by name:  #{@container_name}")
      return Docker::Container.get(@container_name)
    rescue Docker::Error::NotFoundError
      # Container with this name doesn't exist yet, create it
      p("Container not found!")
      create_container
    end
  end
  
  def ensure_image_exists
    begin
      Docker::Image.get(@image_name)
    rescue Docker::Error::NotFoundError
      build_image
    end
  end
end