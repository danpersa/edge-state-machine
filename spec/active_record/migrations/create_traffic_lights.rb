class CreateTrafficLights < ActiveRecord::Migration
  def self.up
    create_table(:traffic_lights, force: true) do |t|
      t.string :state
      t.string :name
    end
  end
end
