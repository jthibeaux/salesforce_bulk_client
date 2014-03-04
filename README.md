[![Code Climate](https://codeclimate.com/github/jthibeaux/salesforce_bulk_client.png)](https://codeclimate.com/github/jthibeaux/salesforce_bulk_client) ![CircleCI](https://circleci.com/gh/:owner/:repo.png?circle-token=:circle-token)

# SalesforceBulkClient

Gem to perform data uploads using the Salesforce Bulk API. This library is only intended to support the bulk API, so salesforce authentication will need to be handled independently (we use the [databasedotcom](https://github.com/heroku/databasedotcom) gem)

## Installation

Add this line to your application's Gemfile:

    gem 'salesforce_bulk_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install salesforce_bulk_client

## Usage

A simplistic usage example of usage is below.

    connection = SalesforceBulkClient::Connection.new(instance_host, salesforce_client.oauth_token)
    api = SalesforceBulkClient::Api.new('23.0')
    job = SalesforceBulkClient::Job.new(api, connection)
    job.create('upsert', 'Account', 'SomeExternalId')
    job.add_batch(<array of hashes>)
    job.close
    job.update_batches
    if (job.all_batches_completed?)
      batch_results = job.all_batch_results[:batches][0]

## Contributing

1. Fork it ( http://github.com/<my-github-username>/salesforce_bulk_client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
