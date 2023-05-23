require 'net/http'
require 'json'
require_relative '../../app/helpers/osmosis_helper'

include OsmosisHelper
def lowest_height_available
  ret = nil
  make_request(
    "/block?height=1",
    -> (body) {},
    -> (body) {
      begin
        ret = body["error"]["data"].scan(/lowest height is (\d+)/)[0][0].to_i
      rescue error
        Rails.logger.error("#{error}: Failed to get lowest_height_available from #{body}")
      end
    }
  )
  ret
end

def current_height
  ret = nil
  make_request(
    "/status",
    -> (body) {
      ret = body["result"]["sync_info"]["latest_block_height"].to_i
    },
    -> (body) {} # TODO: Handle error?
  )
  ret
end

def get_block height
  ret = nil
  make_request(
    "/block?height=#{height}",
    -> (body) {
      ret = {
        height: height,
        n_txs: body["result"]["block"]["data"]["txs"].size,
        txs: body["result"]["block"]["data"]["txs"],
        proposer: body["result"]["block"]["header"]["proposer_address"],
        validators: body["result"]["block"]["last_commit"]["signatures"]
      }
    },
    -> (body) {
      puts "Error: {body}"
    } # TODO: Handle error?
  )
end

namespace :indexer do
  task run: :environment do
    starting = [Block::STARTING_HEIGHT, Block.maximum(:height) || 0].max
    current = current_height()
    puts "Queueing blocks with heights #{starting..current}"
    heights = (starting..current).to_a - Block.where(height: starting..current).map(&:height)
    puts "Creating blocks with heights #{heights}"
    Block.create(heights.map {|ht| [height: ht, status: :queued]})
  end

  task fill: :environment do
    threads = []
    queued_heights = Block.where(status: :queued).map(&:height)
    queued_heights.each_slice(100) do |block_heights|
      threads << Thread.new do
        puts "thread for #{block_heights}"
        ActiveRecord::Base.connection_pool.with_connection do
          block_heights.each do |ht|
            block_params = get_block(ht)
            block = Block.find_or_initialize_by(height: ht)
            block.assign_attributes(block_params)
            block.status = :fetched
            block.save # Error handling?
          end
        end
      end
    end
    threads.map(&:join)
  end
end
