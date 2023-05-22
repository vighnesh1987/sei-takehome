class CreateBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :blocks do |t|
      t.integer :height
      t.integer :n_txs
      t.json :txs
      t.string :proposer
      t.json :validators

      t.timestamps
    end
  end
end
