module Fastlane
  module Helper
    class GenerateHtmlHelper
      # class methods that you define here become available in your action
      # as `Helper::GenerateHtmlHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the generate_html plugin helper!")
      end
    end
  end
end
