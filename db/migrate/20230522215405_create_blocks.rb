class CreateBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :blocks, id: false do |t|
      t.integer :height, primary_key: true
      t.integer :n_txs
      t.json :txs
      t.string :proposer
      t.json :validators
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
