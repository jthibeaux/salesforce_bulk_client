# encoding: UTF-8
require 'spec_helper'

describe SalesforceBulkClient::Api::Xml do
  describe '#job_create' do
    it 'returns xml for creating new job' do
      expect(subject.job_create('upsert', 'Thing')).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<operation>upsert</operation>
<object>Thing</object>
<contentType>XML</contentType>
</jobInfo>
      XML
    end

    context 'external field is included' do
      it 'returns xml for creating new job with external field' do
        expect(subject.job_create(
          'upsert',
          'Thing',
          'xfield')
        ).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<operation>upsert</operation>
<object>Thing</object>
<externalIdFieldName>xfield</externalIdFieldName>
<contentType>XML</contentType>
</jobInfo>
        XML
      end
    end
  end

  describe '#job_close' do
    it 'returns xml formatted correctly for closing job' do
      expect(subject.job_close).to eq <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<state>Closed</state>
</jobInfo>
      XML
    end
  end

  describe '#add_batch' do
    let(:records) do
      [
        {
          a: 'x',
          b: 'y',
        },
        {
          a: 'x2',
          b: 'y2',
        },
      ]
    end

    it 'returns xml formatted correctly for batch' do
      expect(subject.add_batch(records)).to eq <<-XML
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<sObjects xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">
<sObject><a>x</a><b>y</b></sObject><sObject><a>x2</a><b>y2</b></sObject>
</sObjects>
      XML
    end

    context 'batch includes nil values' do
      let(:records) do
        [
          {
            nope: nil,
          },
        ]
      end
      it 'returns xml formatted correctly for batch' do
        expect(subject.add_batch(records)).to eq <<-XML
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<sObjects xmlns=\"http://www.force.com/2009/06/asyncapi/dataload\">
<sObject><nope xsi:nil="true" /></sObject>
</sObjects>
        XML
      end
    end
  end

  describe '#parse_job_info' do
    let(:xml) do
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<jobInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>750D0000000002lIAA</id>
<operation>insert</operation>
<object>Account</object>
<createdById>005D0000001ALVFIA4</createdById>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<state>Closed</state>
</jobInfo>
      XML
    end

    it 'returns job info' do
      expect(subject.parse_job_info(xml)).to eq(
        id: '750D0000000002lIAA',
        state: 'Closed'
      )
    end
  end

  describe '#parse_batch_info' do
    let(:xml) do
      <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<batchInfo xmlns="http://www.force.com/2009/06/asyncapi/dataload">
<id>751D0000000004rIAA</id>
<jobId>750D0000000002lIAA</jobId>
<state>InProgress</state>
<createdDate>2009-04-14T18:15:59.000Z</createdDate>
<systemModstamp>2009-04-14T18:15:59.000Z</systemModstamp>
<numberRecordsProcessed>123</numberRecordsProcessed>
</batchInfo>
      XML
    end

    it 'returns batch info' do
      expect(subject.parse_batch_info(xml)).to eq(
        id: '751D0000000004rIAA',
        state: 'InProgress',
        number_records_processed: 123
      )
    end
  end

  describe '#parse_all_batches' do
    let(:xml) do
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
<id>751D0000000004sIAA</id>
<jobId>750D0000000002lIAA</jobId>
<state>InProgress</state>
<createdDate>2009-04-14T18:16:00.000Z</createdDate>
<systemModstamp>2009-04-14T18:16:09.000Z</systemModstamp>
<numberRecordsProcessed>800</numberRecordsProcessed>
</batchInfo>
</batchInfoList>
      XML
    end

    it 'returns batch info array' do
      expect(subject.parse_all_batches(xml)).to eq(
        batches: [
          {
            id: '751D0000000004rIAA',
            state: 'InProgress',
            number_records_processed: 800
          },
          {
            id: '751D0000000004sIAA',
            state: 'InProgress',
            number_records_processed: 800
          }
        ]
      )
    end
  end

  describe '#parse_batch_result' do
    let(:xml) do
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

    it 'returns batch info array' do
      expect(subject.parse_batch_result(xml)).to eq(
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
      )
    end
  end
end
