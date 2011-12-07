class CreateDoubleMachine < ActiveRecord::Migration
  def self.up
    create_table(:double_machine_active_records, force: true) do |t|
      t.string :state
      t.string :second_state
    end
  end
end