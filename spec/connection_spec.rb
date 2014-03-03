# encoding: UTF-8
require 'spec_helper'

describe SalesforceBulkClient::Connection do

  let(:host) { 'some.host.com' }
  let(:session_id) { 'SOMESESSIONID' }
  let(:path) { '/some_path' }
  let(:xml) { '<some><xml>!</xml></some>' }
  subject { described_class.new(host, session_id) }

  describe '#post_xml' do
    it 'posts xml with appropriate headers' do
      stub_request(:post, "https://#{host}:443#{path}").with(
        headers: {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id,
        },
        body: xml
      ).to_return(body: '<stuff></stuff>')
      subject.post_xml(path, xml)
    end

    it 'retries multiple times when connection times out' do
      stub_request(:post, "https://#{host}:443#{path}").with(
        headers: {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id,
        },
        body: xml,
        times: 3
      ).to_timeout

      expect { subject.post_xml(path, xml) }.to raise_error(
        SalesforceBulkClient::Error::Timeout
      )
    end

    it 'retries multiple times when connection is reset' do
      stub_request(:post, "https://#{host}:443#{path}").with(
        headers: {
          'Content-Type' => 'application/xml; charset=utf-8',
          'X-SFDC-Session' => session_id,
        },
        body: xml,
        times: 3
      ).to_raise(Errno::ECONNRESET)

      expect { subject.post_xml(path, xml) }.to raise_error(
        SalesforceBulkClient::Error::ConnReset
      )
    end
  end

  describe '#get' do
    it 'gets with appropriate headers' do
      stub_request(:get, "https://#{host}:443#{path}").with(
        headers: {
          'X-SFDC-Session' => session_id,
        }
      ).to_return(body: '<stuff></stuff>')
      subject.get(path)
    end

    it 'retries multiple times when connection times out' do
      stub_request(:get, "https://#{host}:443#{path}").with(
        headers: {
          'X-SFDC-Session' => session_id,
        },
        times: 3
      ).to_timeout

      expect { subject.get(path) }.to raise_error(
        SalesforceBulkClient::Error::Timeout
      )
    end

    it 'retries multiple times when connection is reset' do
      stub_request(:get, "https://#{host}:443#{path}").with(
        headers: {
          'X-SFDC-Session' => session_id,
        },
        times: 3
      ).to_raise(Errno::ECONNRESET)

      expect { subject.get(path) }.to raise_error(
        SalesforceBulkClient::Error::ConnReset
      )
    end
  end
end
