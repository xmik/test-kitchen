module TestKitchen
  module Project
    class Cookbook < Ruby

      include SupportedPlatforms

      attr_writer :lint
      attr_writer :supported_platforms

      def initialize(name, &block)
        super(name, &block)
      end

      def lint(arg=nil)
        set_or_return(:lint, arg, {:default => true})
      end

      def language(arg=nil)
        "chef"
      end

      def preflight_command(runtime = nil)
        return nil unless lint
        parent_dir = File.join(root_path, '..')
        cmd = "knife cookbook test -o #{parent_dir} #{name}"
        cmd << " && foodcritic -f ~FC007 -f correctness #{root_path}"
        cmd
      end

      def install_command(runtime=nil)
        "sudo gem update --system; gem install bundler && #{cd} && #{path} bundle install"
      end

      def test_command(runtime=nil)
        %q{#{cd} && if [ -d "features" ]; then #{path} bundle exec cucumber -t @#{name} features; fi}
      end

      def supported_platforms
        @supported_platforms ||= extract_supported_platforms(
          File.read(File.join(root_path, 'metadata.rb')))
      end

      def non_buildable_platforms(platform_names)
        supported_platforms.sort - platform_names.map do |platform|
          platform.split('-').first
        end.sort.uniq
      end

      def each_build(platforms, &block)
        if supported_platforms.empty?
          super(platforms, &block)
        else
          super(platforms.select do |platform|
            supported_platforms.any? do |supported|
              platform.start_with?("#{supported}-")
            end
          end, &block)
        end
      end

      private

      def cd
        "cd #{File.join(guest_test_root, 'test')}"
      end

      def path
        'PATH=$PATH:/var/lib/gems/1.8/bin'
      end

    end
  end
end
