namespace :indexer do
  task run: :environment do
    Block.new(height: 1234).save
  end
end
