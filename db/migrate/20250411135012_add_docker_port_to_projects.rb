class AddDockerPortToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :docker_port, :integer
  end
end
