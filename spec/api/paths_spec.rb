# encoding: UTF-8
require 'spec_helper'

describe SalesforceBulkClient::Api::Paths do
  let(:version) { '29.0' }

  subject do
    SalesforceBulkClient::Api::Paths.new(
      version
    )
  end

  describe '#jobs' do
    it 'returns URI for jobs' do
      expect(subject.jobs).to eq(
        '/services/async/v29.0/job'
      )
    end
  end

  describe '#job' do
    let(:id) { 123 }
    it 'returns URI for job with id' do
      expect(subject.job(id)).to eq(
        "/services/async/v29.0/job/#{id}"
      )
    end
  end

  describe '#batches' do
    let(:job_id) { 321 }
    it 'returns URI for job batches' do
      expect(subject.batches(job_id)).to eq(
        "/services/async/v29.0/job/#{job_id}/batch"
      )
    end
  end

  describe '#batch' do
    let(:job_id) { 321 }
    let(:id) { 123 }
    it 'returns URI for job with id' do
      expect(subject.batch(job_id, id)).to eq(
        "/services/async/v29.0/job/#{job_id}/batch/#{id}"
      )
    end
  end

  describe '#batch_result' do
    let(:job_id) { 321 }
    let(:id) { 123 }
    it 'returns URI for job with id' do
      expect(subject.batch_result(job_id, id)).to eq(
        "/services/async/v29.0/job/#{job_id}/batch/#{id}/result"
      )
    end
  end
end
