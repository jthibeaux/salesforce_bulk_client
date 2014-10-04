# encoding: UTF-8
require 'net/http'

module SalesforceBulkClient
  class Connection
    MAX_RETRY = 3

    attr_reader :session_id, :host

    def initialize(host, session_id)
      @session_id = session_id
      @host = host
    end

    def post_xml(path, xml)
      try_request { try_post_xml(path, xml) }
    end

    def get(path)
      try_request { try_get(path) }
    end

    private

    def raise_exception_for(e)
      case (e)
      when Timeout::Error
        raise SalesforceBulkClient::Error::Timeout, e.message
      when Errno::ECONNRESET
        raise SalesforceBulkClient::Error::ConnReset, e.message
      end
    end

    def try_request(&_block)
      tries = 0
      while tries < MAX_RETRY
        begin
          return yield
        rescue Timeout::Error, Errno::ECONNRESET => e
          tries += 1

          raise_exception_for(e) unless tries < MAX_RETRY
          reset
        end
      end
    end

    def try_post_xml(path, xml)
      post = Net::HTTP::Post.new(path)
      post['X-SFDC-Session'] = session_id
      post['Content-Type'] = 'application/xml; charset=utf-8'
      post.body = xml
      http.request(post)
    end

    def try_get(path)
      get = Net::HTTP::Get.new(path)
      get['X-SFDC-Session'] = session_id
      http.request(get)
    end

    def http
      @http ||= begin
        http = Net::HTTP.new(host, 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http
      end
    end

    def reset
      @http.finish if @http && @http.active?
      @http = nil
    end
  end
end
