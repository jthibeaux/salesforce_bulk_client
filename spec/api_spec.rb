# encoding: UTF-8
require 'spec_helper'

describe SalesforceBulkClient::Api do
  let(:version) { '29.0' }

  subject do
    SalesforceBulkClient::Api.new(
      version
    )
  end

  it 'includes paths instance' do
    expect(subject.paths).to_not be_nil
  end

  it 'includes an xml instance' do
    expect(subject.xml).to_not be_nil
  end
end
