require_relative '../spec_helper'

require 'test-kitchen'

module TestKitchen
  describe Environment do
    describe "#initialize" do
      it "accepts an additional custom name for the kitchen file" do
        env = Environment.new({:kitchenfile_name => 'Cucinafile', :ignore_kitchenfile => true})
        env.kitchenfile_name.must_equal ['Cucinafile', 'Kitchenfile', 'kitchenfile']
      end
      it "accepts an additional custom name for the kitchen file as an array" do
        env = Environment.new({:kitchenfile_name => ['Cucinafile', 'cucinafile'], :ignore_kitchenfile => true})
        env.kitchenfile_name.must_equal ['Cucinafile', 'cucinafile', 'Kitchenfile', 'kitchenfile']
      end
      it "raises if the kitchenfile could not be located" do
        lambda { env = Environment.new }.must_raise(ArgumentError)
      end
      it "doesn't raise if the kitchenfile should be ignored" do
        env = Environment.new({:ignore_kitchenfile => true})
      end
      it "sets the temp scratch directory to a path under the root directory" do
        env = Environment.new({:ignore_kitchenfile => true})
        env.tmp_path.to_s.must_equal(File.join(env.root_path, '.kitchen'))
      end
      it "sets the cache directory to a path under the temporary directory" do
        env = Environment.new({:ignore_kitchenfile => true})
        env.cache_path.to_s.must_equal(File.join(env.tmp_path, '.cache'))
      end
    end
    describe "platforms" do
      let(:env) do
        env = Environment.new({:ignore_kitchenfile => true})
        env.platforms['ubuntu'] = Platform.new(:ubuntu) do
          version '10.04' do
            box "ubuntu-10.04"
            box_url "http://example.org/ubuntu-10.04.box"
          end
          version '11.04' do
            box "ubuntu-11.04"
            box_url "http://example.org/ubuntu-11.04.box"
          end
        end
        env
      end
      describe "#all_platforms" do
        it "flattens the nested platforms to a hash" do
          env.all_platforms.keys.must_equal(['ubuntu-10.04', 'ubuntu-11.04'])
          env.all_platforms['ubuntu-10.04'].wont_be_nil
          env.all_platforms['ubuntu-11.04'].wont_be_nil
        end
      end
      describe "#platform_names" do
        it "returns a list of platform names" do
          env.platform_names.must_equal(['ubuntu-10.04', 'ubuntu-11.04'])
        end
      end
    end
  end
end
