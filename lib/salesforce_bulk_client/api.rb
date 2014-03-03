# encoding: UTF-8
class SalesforceBulkClient::Api
  require 'salesforce_bulk_client/api/paths'
  require 'salesforce_bulk_client/api/xml'

  attr_reader :paths, :xml

  def initialize(version)
    @paths = SalesforceBulkClient::Api::Paths.new(version)
    @xml = SalesforceBulkClient::Api::Xml.new
  end
end
