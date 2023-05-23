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
      ret = Block.new(
        height: height,
        n_txs: body["result"]["block"]["data"]["txs"].size,
        txs: body["result"]["block"]["data"]["txs"],
        proposer: body["result"]["block"]["header"]["proposer_address"],
        validators: body["result"]["block"]["last_commit"]["signatures"]
      )
    },
    -> (body) {} # TODO: Handle error?
  )
end

namespace :indexer do
  task run: :environment do
    starting = [Block::STARTING_HEIGHT, Block.maximum(:height) || 0].max
    current = current_height()
    puts "Queueing blocks with heights #{starting..current}"
    Block.create((starting..current).map {|ht| [height: ht, status: :queued]})
  end

  task fill: :environment do
    threads = []
    Block.where(status: :queued).each do |block|
      threads << Thread.new do
        block = get_block(block.height)
        block.status = :fetched
        # Error handling?
        block.save
      end
    end
    threads.map(&:join)
  end
end
