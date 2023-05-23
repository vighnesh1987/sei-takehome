class AddStatusToBlock < ActiveRecord::Migration[7.0]
  def change
    add_column :blocks, :status, :integer, default: 0
  end
end
