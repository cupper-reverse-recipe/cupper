require 'spec_helper'

describe Cupper::Cli do

  let(:cli) do
    Cupper::Cli.new
  end

  describe 'command create' do
    it 'should create a project with a given name'
  end

  describe 'command ohai_plugins' do
    it 'should return a list of ohai_plugins' do
      expect_any_instance_of(Cupper::OhaiPlugin).to receive(:list).and_return(['plugin1'])
      command = cli.ohai_plugins
      expect(command).to eq(['plugin1'])
    end
  end
end
