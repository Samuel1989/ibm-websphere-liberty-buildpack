# Encoding: utf-8
# IBM WebSphere Application Server Liberty Buildpack
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'liberty_buildpack/util'
require 'liberty_buildpack/util/configuration_utils'
require 'logging_helper'
require 'pathname'
require 'spec_helper'
require 'yaml'

describe LibertyBuildpack::Util::ConfigurationUtils do
  include_context 'logging_helper'

  it 'not load absent configuration file' do
    allow_any_instance_of(Pathname).to receive(:exist?).and_return(false)
    expect(described_class.load('test')).to eq({})
  end

  context do

    before do
      allow_any_instance_of(Pathname).to receive(:exist?).and_return(true)
      allow(YAML).to receive(:load_file).and_return('foo' => { 'one' => '1', 'two' => 2 },
                                                    'bar' => { 'alpha' => { 'one' => 'cat', 'two' => 'dog' } })
    end

    it 'load configuration file' do
      expect(described_class.load('test')).to eq('foo' => { 'one' => '1', 'two' => 2 },
                                                 'bar' => { 'alpha' => { 'one' => 'cat', 'two' => 'dog' } })
    end

    context do

      let(:environment) do
        { 'JBP_CONFIG_TEST' => '[bar: {alpha: {one: 3, two: {one: 3}}, bravo: newValue}, foo: lion]' }
      end

      it 'overlays matching environment variables' do

        expect(described_class.load('test')).to eq('foo' => { 'one' => '1', 'two' => 2 },
                                                   'bar' => { 'alpha' => { 'one' => 3, 'two' => 'dog' } })
      end

    end

  end

end
