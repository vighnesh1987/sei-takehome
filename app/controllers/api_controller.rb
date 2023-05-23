class ApiController < ApplicationController
  def number_of_transactions_made
    if params[:n].nil? then
      render json: { error: "Parameter 'n' is required for number of blocks"}, status: :unprocessable_entity
    else
      n_txs = Block.where(status: :fetched).order(height: :desc).limit(params[:n].to_i).sum(:n_txs)
      render json: { n_txs: n_txs}
    end
  end

  def blocks_proposed_by_validator
    if params[:proposer].nil? then
      render json: {error: "Parameter 'proposer' is required for address of proposer"}, status: :unprocessable_entity
    else
      blocks = Block.where(proposer: params[:proposer]).map(&:as_json)
      render json: { blocks: blocks }
    end
  end
end
