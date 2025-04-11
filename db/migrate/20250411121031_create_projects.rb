class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :docker_container_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
