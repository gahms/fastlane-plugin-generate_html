module Fastlane
  module Actions
    class GenerateHtmlAction < Action
      def self.run(params)
        UI.message("The generate_html plugin is working!")
      end

      def self.description
        "Generate HTML files for easy install of ipa or apk on a phone"
      end

      def self.authors
        ["Nicolai Henriksen"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin will generate a set of files that can be used to upload to a web-server. When loaded on a phone the user will be able to tap a link to install the ipa or apk."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "GENERATE_HTML_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
