# encoding: UTF-8
require 'spec_helper'
require 'json'

describe 'Rubocop' do
  it 'passes with 0 offenses' do
    result = JSON.parse(`bundle exec rubocop --format json`)
    expect(result['summary']['offence_count']).to eq 0
  end
end
