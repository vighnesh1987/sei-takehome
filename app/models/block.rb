class Block < ApplicationRecord
  enum status: { queued: 0, fetched: 1}
  STARTING_HEIGHT = 9759513
end
