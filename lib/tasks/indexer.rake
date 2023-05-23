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
        Rails.logger.error "[lowest_height_available()]: Failed to get lowest_height_available from #{body}, #{error}"
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
    -> (body) {
      Rails.logger.error "[current_height()]: #{body}"
    }
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
      Rails.logger.error "[get_block(#{height})]: #{body}"
    }
  )
end

namespace :indexer do
  task run: :environment do
    starting = [Block::STARTING_HEIGHT, Block.maximum(:height) || 0].max
    current = current_height()
    Rails.logger.debug "Queueing blocks with heights #{starting..current}"
    heights = (starting..current).to_a - Block.where(height: starting..current).map(&:height)
    Rails.logger.debug "Creating blocks with heights #{heights}"
    begin
      Block.create(heights.map {|ht| [height: ht, status: :queued]})
    rescue error
      Rails.logger.error "[indexer:run] #{error}"
    end
  end

  task fill: :environment do
    threads = []
    queued_heights = Block.where(status: :queued).map(&:height)
    queued_heights.each_slice(100) do |block_heights|
      threads << Thread.new do
        Rails.logger.debug "thread for #{block_heights}"
        ActiveRecord::Base.connection_pool.with_connection do
          block_heights.each do |ht|
            block_params = get_block(ht)
            block = Block.find_or_initialize_by(height: ht)
            block.assign_attributes(block_params)
            block.status = :fetched
            begin
              block.save # Error handling?
            rescue error
              Rails.logger.error "[indexer:fill] height: #{ht} #{error}"
            end
            Rails.logger.debug "Saved #{block.height}"
          end
        end
      end
    end
    threads.map(&:join)
  end
end
