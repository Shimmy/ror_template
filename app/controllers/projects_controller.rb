class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy build_container start_container stop_container ]

  # GET /projects
  def index
    @projects = Project.all
    respond_to do |format|
      format.html
      format.json { render json: ProjectDatatable.new(params) }
    end
  end

  # GET /projects/1
  def show
  end

  # POST /projects/:id/build_container
  def build_container
    DockerManager.new(@project).build_image
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update('docker-output', partial: 'projects/docker_status', locals: { notice: 'Docker image built.' }) }
      format.html { redirect_to @project, notice: 'Docker image built.' }
    end
  end

  # POST /projects/:id/start_container
  def start_container
    DockerManager.new(@project).start_container
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update('docker-output', partial: 'projects/docker_status', locals: { notice: 'Docker container started.' }) }
      format.html { redirect_to @project, notice: 'Docker container started.' }
    end
  end

  # POST /projects/:id/stop_container
  def stop_container
    DockerManager.new(@project).stop_container
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update('docker-output', partial: 'projects/docker_status', locals: { notice: 'Docker container stopped.' }) }
      format.html { redirect_to @project, notice: 'Docker container stopped.' }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy!
    redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, :docker_container_id, :user_id)
    end
end
