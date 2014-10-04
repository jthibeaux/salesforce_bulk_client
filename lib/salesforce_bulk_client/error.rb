# encoding: UTF-8
module SalesforceBulkClient
  module Error
    class Timeout < StandardError; end
    class ConnReset < StandardError; end
    class Salesforce < StandardError; end
  end
end
