require 'spec_helper'

describe Cupper::Collect do

  let(:collect) do
    Cupper::Collect.new
  end

  let(:link_extraction) do
    [ { 'link' => 'links' } ]
  end

  it 'should extract the attribute' do
    allow(collect).to receive(:platform).and_return('debian')
    expect_any_instance_of(Cupper::Debian).to receive(:files).and_return(link_extraction)
    extract = collect.extract 'files'
    expect(extract).to eq(link_extraction)
  end

  it 'should return the platform' do
    collect.instance_variable_set(:@data_extraction, { 'platform_family' => { 'platform_family' => 'debian' } })
    expect(collect.platform).to eq('debian')
    expect(collect.platform).not_to eq('arch')
  end

  it 'should return the data extraction' do
    collect.instance_variable_set(:@data_extraction, {  })
    expect(collect.data).to eq({})
  end
end

