# encoding: UTF-8
class SalesforceBulkClient::Api::Paths
  def initialize(version)
    @version = version
  end

  def jobs
    "#{root}/job"
  end

  def job(id)
    "#{root}/job/#{id}"
  end

  def batches(job_id)
    "#{root}/job/#{job_id}/batch"
  end

  def batch(job_id, id)
    "#{root}/job/#{job_id}/batch/#{id}"
  end

  def batch_result(job_id, id)
    "#{root}/job/#{job_id}/batch/#{id}/result"
  end

  def root
    "/services/async/#{@version}"
  end
end
