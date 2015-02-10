#
# Copyright:: Copyright (c) 2015 Chef Software, Inc
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Knife::SubcommandLoader do
  let(:loader) { Chef::Knife::SubcommandLoader.new(File.join(CHEF_SPEC_DATA, 'knife-site-subcommands')) }
  let(:home) { File.join(CHEF_SPEC_DATA, 'knife-home') }
  let(:plugin_dir) { File.join(home, '.chef', 'plugins', 'knife') }

  before do
    allow(ChefConfig).to receive(:windows?) { false }
    Chef::Util::PathHelper.class_variable_set(:@@home_dir, home)
  end

  after do
    Chef::Util::PathHelper.class_variable_set(:@@home_dir, nil)
  end

  let(:config_dir) { File.join(CHEF_SPEC_DATA, 'knife-site-subcommands') }

  describe "#for_config" do
    context "when ~/.chef/plugin_manifest.json exists" do
      before do
        allow(File).to receive(:exist?).with(File.join(ENV['HOME'], '.chef', 'plugin_manifest.json')).and_return(true)
      end

      it "creates a HashedCommandLoader with the manifest has _autogenerated_command_paths" do
        allow(File).to receive(:read).with(File.join(ENV['HOME'], '.chef', 'plugin_manifest.json')).and_return("{ \"_autogenerated_command_paths\": {}}")
        expect(Chef::Knife::SubcommandLoader.for_config(config_dir)).to be_a Chef::Knife::SubcommandLoader::HashedCommandLoader
      end

      it "creates a CustomManifestLoader with then manifest has a key other than _autogenerated_command_paths" do
        allow(File).to receive(:read).with(File.join(ENV['HOME'], '.chef', 'plugin_manifest.json')).and_return("{ \"plugins\": {}}")
        expect(Chef::Knife::SubcommandLoader.for_config(config_dir)).to be_a Chef::Knife::SubcommandLoader::CustomManifestLoader
      end
    end

    context "when ~/.chef/plugin_manifest.json does not exist" do
      before do
        allow(File).to receive(:exist?).with(File.join(ENV['HOME'], '.chef', 'plugin_manifest.json')).and_return(false)
      end

      it "creates a GemGlobLoader" do
        expect(Chef::Knife::SubcommandLoader.for_config(config_dir)).to be_a Chef::Knife::SubcommandLoader::GemGlobLoader
      end
    end
  end
end
