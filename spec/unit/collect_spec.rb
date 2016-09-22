require 'spec_helper'

describe Cupper::Collect do

  let(:collect) do
    Cupper::Collect.new
  end

  it 'should setup the plugins with Ohai' do
  end

  it 'should extract the attribute' do
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

