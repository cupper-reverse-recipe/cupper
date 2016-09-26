require 'spec_helper'
require 'cupper/environment'

describe Cupper::Environment do

  let(:env) do
    Cupper::Environment.new
  end

  it 'should have a invalid env without a Cupperfile' do
    allow(File).to receive(:exist?).and_return(false)
    allow(env).to receive(:find_cupperfile).and_return(nil)
    expect(env.root_path).to be(nil)
  end


end
