# encoding: UTF-8
require 'xmlsimple'

class SalesforceBulkClient::Api::Xml
  @xmlns = 'http://www.force.com/2009/06/asyncapi/dataload'
  @xmlheader = '<?xml version="1.0" encoding="UTF-8"?>'

  class << self
    attr_accessor :xmlns, :xmlheader
  end

  def job_create(operation, object_type, external_field = nil)
    <<-XML
#{self.class.xmlheader}
<jobInfo xmlns="#{self.class.xmlns}">
<operation>#{operation}</operation>
<object>#{object_type}</object>
#{external_field_xml(external_field)}<contentType>XML</contentType>
</jobInfo>
    XML
  end

  def job_close
    <<-XML
#{self.class.xmlheader}
<jobInfo xmlns="#{self.class.xmlns}">
<state>Closed</state>
</jobInfo>
    XML
  end

  def add_batch(records)
    <<-XML
#{self.class.xmlheader}
<sObjects xmlns="#{self.class.xmlns}">
#{batch_records(records)}
</sObjects>
    XML
  end

  def parse_job_info(xml)
    parsed = XmlSimple.xml_in(xml)
    transform_job_info(parsed)
  end

  def parse_batch_info(xml)
    parsed = XmlSimple.xml_in(xml)
    transform_batch_info(parsed)
  end

  def parse_all_batches(xml)
    parsed = XmlSimple.xml_in(xml)
    transform_batches(parsed)
  end

  def parse_batch_result(xml)
    parsed = XmlSimple.xml_in(xml)
    transform_batch_result(parsed)
  end

  protected

  def external_field_xml(external_field)
    return '' unless external_field
    "<externalIdFieldName>#{external_field}</externalIdFieldName>\n"
  end

  def salesforce_exception?(data)
    !data['exceptionCode'].nil?
  end

  def transform_salesforce_exception(data)
    {
      exception_code: data['exceptionCode'][0],
      exception_message: data['exceptionMessage'][0]
    }
  end

  def transform_salesforce_bad_batch(data)
    {
      state: data['state'][0],
      state_message: data['stateMessage'][0]
    }
  end

  def transform_job_info(data)
    return transform_salesforce_exception(data) if salesforce_exception?(data)
    {
      id: data['id'][0],
      state: data['state'][0],
    }
  end

  def transform_batch_info(data)
    return transform_salesforce_exception(data) if salesforce_exception?(data)
    {
      id: data['id'][0],
      state: data['state'][0],
      number_records_processed: data['numberRecordsProcessed'][0].to_i,
    }
  end

  def transform_batches(data)
    return transform_salesforce_exception(data) if salesforce_exception?(data)
    batches = data['batchInfo'].map do |batch_info|
      transform_batch_info(batch_info)
    end
    { batches: batches }
  end

  def transform_batch_result(data)
    return transform_salesforce_exception(data) if salesforce_exception?(data)
    return transform_salesforce_bad_batch(data) unless data['result']

    results = data['result'].map do |batch_info|
      result = {}
      batch_info.keys.each do |key|
        result[key.to_sym] = batch_info[key][0]
      end
      result
    end
    { results: results }
  end

  def nil_attributes(record)
    with_nils = record.clone
    with_nils.keys.each do |k|
      if with_nils[k].nil?
        with_nils[k] = {
          '@xsi:nil' => true
        }
      end
    end
    with_nils
  end

  def batch_record(record)
    XmlSimple.xml_out(
      nil_attributes(record),
      'AttrPrefix' => true,
      'RootName' => 'sObject',
      'NoIndent' => true,
      'SuppressEmpty' => nil,
    )
  end

  def batch_records(records)
    records.map do |r|
      batch_record(r)
    end.join('')
  end
end
