# Indexer + API

Rails introduces a lot of boiler plate. Ignore most of it other than the files I reference here.

## Indexer
Indexing of the Osmosis blocks happens via two Rake tasks which are run on crontab via the Ruby gem
`whenever`. You can find this logic inside `indexer.rake`

Run these jobs with `bundle exec whenever --update-crontab`. Close these jobs with `bundle exec whenever --clear-crontab`. These jobs pick up updated script logic automatically.

You can find logs in log/development.log and log/error.log. Errors are typically due to reaching limit of db connections or failing https request. The code is designed to just log the errors for checking every now and then, but retry logic is in place, so don't need to worry about the errors.

## API
A JSON API is exposed. Start the Rails server `rails server`. It'll pipe out where it's started, typically `localhost:3000`. The routes are defined in `config/routes.rb`.

You can hit these endpoints for the requirements mentioned in the prompt.
http://127.0.0.1:3000/api/v1/blocks_proposed_by_validator?proposer=60A433D28B08788C72E2133554BD5CC68769DCEC

http://127.0.0.1:3000/api/v1/number_of_transactions_made?n=4

## Database
You can explore everything that's stored inside `rails dbconsole`. I've used SQLite as the database.


## Unanswered questions about peer scores
Firstly, in "Top N peers based on score over the last N blocks", is N an argument?

If so, I was able to locate "peers" on the Cosmosis page, but unable to find any information about their "scores" per block. When I query /net_info, I see a `connection_status.Duration`, which seems like an input to the score, but not the score itself.

When I explore Osmosis and Cosmos using ChatGPT, it tells me that the peer scores are not exposed in a public API – of course this could be an instance of ChatGPT hallucinating :)

/net_info also directly provides `n_peers` but it doesn't take a parameter "N", in case N is an argument. If N is not an argument, then perhaps that third query in the API just needs the results directly from /net_info?



----

## Prompt

(Copied from email with ignored requirements striked out)

Indexer Prompt
You should also create an API for Osmosis that supports the following queries:

1. Which blocks validator X has proposed
2. How many transactions were made in the last N blocks
3. ~~Top N peers based on score over the last N blocks~~

To get the data for this API, we want you to create an indexer that parses new blocks and tracks the following information at each height

1. Basic transaction information
2. Validator data for height
3. ~~Network information for peer score (only peers with scores) for each block~~

The indexer should schedule data collection at regular intervals (i.e. every 30 seconds) and store the data in a structured format (JSON, CSV, relational database...etc). Include proper error handling and data validation to ensure data consistency and reliability. This means that if the indexer service is restarted, we should be able to re-run the indexer to backfill the data.

### Deliverable

1. A github repo with indexer and API code
2. An indexer which has started indexing data from some starting height (let us know what the starting height is, it can be the current height instead of starting from height 0)
3. An API + instructions to perform the above queries


### Resources

Feel free to look for an RPC endpoint on https://cosmos.directory/osmosis to use to explore data.
RPC endpoint documentation can be found here: https://docs.tendermint.com/v0.34/rpc/#/
