# encoding: UTF-8
require 'spec_helper'

describe SalesforceBulkClient::Job do
  let(:api) { SalesforceBulkClient::Api.new('29.0') }
  let(:host) { 'www.somehost.com' }
  let(:session_id) { 'ASESSIONID' }
  let(:connection) { SalesforceBulkClient::Connection.new(host, session_id) }
  let(:path) { '/' }
  let(:url) { "https://#{host}:443#{path}" }
  subject { described_class.new(api, connection) }

  describe '#create' do
    let(:operation) { 'upsert' }
    let(:object_type) { 'Account' }
    let(:path) { '/services/async/29.0/job' }
    let(:request_body) do
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<operation>upsert</operation>
<object>Account</object>
<contentType>XML</contentType>
</jobInfo>
      XML
    end
    let(:response_body) do
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>750D0000000002lIAA</id>
<operation>upsert</operation>
<object>Account</object>
<createdById>005D0000001ALVFIA4</createdById>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<state>Open</state>
<contentType>XML</contentType>
</jobInfo>
      XML
    end

    it 'should post xml to the appropriate path' do
      stub_request(:post, url).with(
        body: request_body
      ).to_return(body: response_body)
      subject.create(operation, object_type)
      expect(subject.id).to eq '750D0000000002lIAA'
      expect(subject.state).to eq 'Open'
    end
  end

  context 'job created' do
    let(:job_info) do
      {
        id: job_id,
        state: state
      }
    end
    let(:job_id) { '750D0000000002lIAA' }
    let(:state) { 'Open' }

    before do
      subject.instance_variable_set(:@job_info, job_info)
    end

    describe '#close' do
      let(:path) { "/services/async/29.0/job/#{job_id}" }
      let(:request_body) do
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<state>Closed</state>
</jobInfo>
        XML
      end
      let(:response_body) do
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>750D0000000002lIAA</id>
<operation>upsert</operation>
<object>Account</object>
<createdById>005D0000001ALVFIA4</createdById>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<state>Closed</state>
<contentType>XML</contentType>
</jobInfo>
        XML
      end

      it 'should post xml to the appropriate path' do
        stub_request(:post, url).with(
          body: request_body
        ).to_return(body: response_body)
        subject.close
        expect(subject.id).to eq '750D0000000002lIAA'
        expect(subject.state).to eq 'Closed'
      end
    end

    describe '#update' do
      let(:path) { "/services/async/29.0/job/#{job_id}" }
      let(:response_body) do
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>750D0000000002lIAA</id>
<operation>upsert</operation>
<object>Account</object>
<createdById>005D0000001ALVFIA4</createdById>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<state>Closed</state>
<contentType>XML</contentType>
</jobInfo>
        XML
      end

      it 'should get the appropriate path and update job info' do
        stub_request(:get, url).to_return(body: response_body)
        subject.update
        expect(subject.id).to eq '750D0000000002lIAA'
        expect(subject.state).to eq 'Closed'
      end
    end

    describe '#add_batch' do
      let(:path) { "/services/async/29.0/job/#{job_id}/batch" }
      let(:records) do
        [
          {
            x: 'a',
            y: 'b'
          },
          {
            x: 'c',
            y: 'd'
          }
        ]
      end
      let(:request_body) do
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<sObjects xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<sObject><x>a</x><y>b</y></sObject><sObject><x>c</x><y>d</y></sObject>
</sObjects>
        XML
      end

      let(:response_body) do
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<batchInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>751D0000000004rIAA</id>
<jobId>750D0000000002lIAA</jobId>
<state>Queued</state>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<numberRecordsProcessed>0</numberRecordsProcessed>
</batchInfo>
        XML
      end

      it 'should post xml to the appropriate path and initialize batch info' do
        stub_request(:post, url).with(
          body: request_body
        ).to_return(body: response_body)
        subject.add_batch(records)
        expect(subject.batches.length).to eq 1
        batch = subject.batches[0]
        expect(batch[:id]).to eq '751D0000000004rIAA'
        expect(batch[:state]).to eq 'Queued'
        expect(batch[:number_records_processed]).to eq 0
      end
    end

    context 'batches added' do
      let(:state1) { 'Queued' }
      let(:state2) { 'Queued' }
      let(:batches) do
        [
          {
            id: '751D0000000004rIAA',
            state: state1,
            num_records_processed: 0,
          },
          {
            id: '751D0000000004rIAB',
            state: state2,
            num_records_processed: 0,
          },
        ]
      end

      before do
        subject.instance_variable_set(:@batches, batches)
      end

      describe '#update_batches' do
        let(:path) { "/services/async/29.0/job/#{job_id}/batch" }
        let(:response_body) do
          <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<batchInfoList xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<batchInfo>
<id>751D0000000004rIAA</id>
<jobId>750D0000000002lIAA</jobId>
<state>InProgress</state>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:16:09.000Z</systemModstamp>
<numberRecordsProcessed>800</numberRecordsProcessed>
</batchInfo>
<batchInfo>
<id>751D0000000004rIAB</id>
<jobId>750D0000000002lIAA</jobId>
<state>InProgress</state>
<createdDate>2009-04-14T18:16:00.000Z</createdDate>
<systemModstamp>2009-04-14T18:16:09.000Z</systemModstamp>
<numberRecordsProcessed>800</numberRecordsProcessed>
</batchInfo>
</batchInfoList>
          XML
        end

        it 'should get the appropriate url and update batch info' do
          stub_request(:get, url).to_return(body: response_body)
          subject.update_batches
          expect(subject.batches).to eq([
            {
              id: '751D0000000004rIAA',
              state: 'InProgress',
              number_records_processed: 800
            },
            {
              id: '751D0000000004rIAB',
              state: 'InProgress',
              number_records_processed: 800
            }
          ])
        end
      end

      describe '#all_batches_completed?' do
        context 'all batches are Queued' do
          it 'returns false' do
            expect(subject.all_batches_completed?).to be_false
          end
        end

        context 'all batches are in progress' do
          let(:state1) { 'InProgress' }
          let(:state2) { 'InProgress' }

          it 'returns false' do
            expect(subject.all_batches_completed?).to be_false
          end
        end

        context 'batches completed' do
          let(:state1) { 'Completed' }
          context 'only 1' do
            it 'returns false' do
              expect(subject.all_batches_completed?).to be_false
            end
          end

          context 'all' do
            let(:state2) { 'Completed' }

            it 'returns true' do
              expect(subject.all_batches_completed?).to be_true
            end
          end
        end

        context 'batches failed' do
          let(:state1) { 'Failed' }
          context 'only 1' do
            it 'returns false' do
              expect(subject.all_batches_completed?).to be_false
            end
          end

          context 'all' do
            let(:state2) { 'Failed' }

            it 'returns true' do
              expect(subject.all_batches_completed?).to be_true
            end
          end
        end
      end

      describe '#all_batch_results' do
        let(:batch_id) { '751D0000000004rIAA' }
        let(:batches) do
          [
            {
              id: batch_id,
              state: 'Completed',
              num_records_processed: 2,
            }
          ]
        end
        let(:path) do
          "/services/async/29.0/job/#{job_id}/batch/#{batch_id}/result"
        end
        let(:response_body) do
          <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<results xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<result>
<id>001D000000ISUr3IAH</id><success>true</success><created>true</created>
</result>
<result>
<id>001D000000ISUr4IAH</id><success>true</success><created>true</created>
</result>
</results>
          XML
        end

        it 'should get the appropriate url and return batch results' do
          stub_request(:get, url).to_return(body: response_body)
          expect(subject.all_batch_results).to eq(
            batches: [
              {
                results: [
                  {
                    id: '001D000000ISUr3IAH',
                    success: 'true',
                    created: 'true',
                  },
                  {
                    id: '001D000000ISUr4IAH',
                    success: 'true',
                    created: 'true',
                  }
                ]
              }
            ]
          )
        end
      end
    end
  end
end
