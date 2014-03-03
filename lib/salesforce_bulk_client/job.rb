# encoding: UTF-8
class SalesforceBulkClient::Job
  attr_reader :api, :connection, :job_info, :batches

  def initialize(api, connection)
    @api = api
    @connection = connection
    @batches = []
  end

  def id
    job_info[:id]
  end

  def state
    job_info[:state]
  end

  def create(operation, object_type, external_field = nil)
    response = connection.post_xml(
      api.paths.jobs,
      api.xml.job_create(operation, object_type, external_field)
    )
    info = api.xml.parse_job_info(response.body)
    raise_if_exception(info)
    @job_info = info
  end

  def close
    response = connection.post_xml(
      api.paths.job(id),
      api.xml.job_close
    )
    info = api.xml.parse_job_info(response.body)
    raise_if_exception(info)
    @job_info = info
  end

  def update
    response = connection.get(
      api.paths.job(id)
    )
    info = api.xml.parse_job_info(response.body)
    raise_if_exception(info)
    @job_info = info
  end

  def add_batch(records)
    response = connection.post_xml(
      api.paths.batches(id),
      api.xml.add_batch(records)
    )
    info = api.xml.parse_batch_info(response.body)
    raise_if_exception(info)
    @batches << info
    info
  end

  def update_batches
    response = connection.get(
      api.paths.batches(id)
    )
    info = api.xml.parse_all_batches(response.body)
    raise_if_exception(info)
    @batches = info[:batches]
  end

  def all_batches_completed?
    @batches.length == completed_batches.length
  end

  def all_batch_results
    batches = @batches.map do |batch_info|
      batch_result(batch_info[:id])
    end
    { batches: batches }
  end

  private

  def raise_if_exception(info)
    raise(
      SalesforceBulkClient::Error::Salesforce,
      "#{info[:exception_message]} (#{info[:exception_code]})"
    ) if info[:exception_code]
  end

  def completed_batches
    @batches.select { |batch_info| batch_completed?(batch_info) }
  end

  def batch_completed?(batch_info)
    !%w(Queued InProgress).include?(batch_info[:state])
  end

  def batch_result(batch_id)
    response = connection.get(
      api.paths.batch_result(id, batch_id)
    )
    info = api.xml.parse_batch_result(response.body)
    raise_if_exception(info)
    info
  end
end
