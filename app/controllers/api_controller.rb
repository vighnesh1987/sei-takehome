class ApiController < ApplicationController
  def number_of_transactions_made
    respond_to do |format|
      format.json { render json: { message: 'Custom method response' } }
    end
  end

  def blocks_proposed_by_validator
    respond_to do |format|
      format.json { render json: { message: 'Custom method response' } }
    end
  end
end
