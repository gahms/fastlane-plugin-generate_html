# rubocop:disable Metrics/AbcSize
require 'fastlane/erb_template_helper'
include ERB::Util
require 'ostruct'
require 'cgi'

module Fastlane
  module Actions
    class GenerateHtmlAction < Action
      def self.run(params)
        UI.message("The generate_html plugin is working!")

        params[:app_file] = config[:app_file]
        params[:plist_template_path] = config[:plist_template_path]
        params[:plist_file_name] = config[:plist_file_name]
        params[:html_template_path] = config[:html_template_path]
        params[:html_file_name] = config[:html_file_name]
        params[:version_template_path] = config[:version_template_path]
        params[:version_file_name] = config[:version_file_name]
        params[:output_directory] = config[:output_directory]

        app_file = params[:app_file]

        UI.user_error!("No IPA or APK file path given, pass using `app_file: 'ipa/apk path'`") if app_file.to_s.length == 0

        file_type = File.extname(app_file).downcase
        if file_type == "ipa"
          app_info = get_ios_app_info(ipa_file)
        else
          app_info = get_android_app_info(apk_file)
        end

        app_info[:full_version] = version_string(bundle_version, build_num)
        app_info[:short_version] = version_short_string(bundle_version, build_num)

        output_directory = "#{app_info[:short_version]}"
        if params[:output_directory]
          output_directory = "#{params[:output_directory]}/#{output_directory}"
        end
        app_file_base = File.basename(app_file)

        FileUtils.mkdir_p(output_directory)
        FileUtils.cp(app_file, output_directory)

        plist_file_name ||= "#{output_directory}/#{URI.escape(app_info[:name].delete(' '))}.plist"
        plist_render = render_file(params[:plist_template_path], "plist_template", app_info)
        File.open(plist_file_name, 'w') { |file| file.write(plist_render) }

        html_file_name ||= "#{output_directory}/index.html"
        html_render = render_file(params[:html_template_path], "html_template", app_info)
        File.open(html_file_name, 'w') { |file| file.write(html_render) }

        version_file_name ||= "#{output_directory}/version.json"
        version_render = render_file(params[:version_template_path], "version_template", app_info)
        File.open(version_file_name, 'w') { |file| file.write(version_render) }
      end

      def render_file(template_file, default_template_file, app_info)
        if template_file && File.exist?(template_file)
          output_template = eth.load_from_path(template_file)
        else
          output_template = eth.load(default_template_file)
        end
        output_render = eth.render(output_template, app_info)
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
          FastlaneCore::ConfigItem.new(key: :app_file,
                                       env_name: "",
                                       description: ".apk or .ipa file for the build ",
                                       optional: true,
                                       default_value: ""),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "",
                                       description: ".apk file for the build ",
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "",
                                       description: ".ipa file for the build ",
                                       optional: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]),
         FastlaneCore::ConfigItem.new(key: :plist_template_path,
                                      env_name: "",
                                      description: "plist template path",
                                      optional: true),
         FastlaneCore::ConfigItem.new(key: :plist_file_name,
                                      env_name: "",
                                      description: "plist filename",
                                      optional: true),
         FastlaneCore::ConfigItem.new(key: :html_template_path,
                                      env_name: "",
                                      description: "html erb template path",
                                      optional: true),
         FastlaneCore::ConfigItem.new(key: :html_file_name,
                                      env_name: "",
                                      description: "html filename",
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :version_template_path,
                                       env_name: "",
                                       description: "version erb template path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :version_file_name,
                                       env_name: "",
                                       description: "version filename",
                                       optional: true),
         FastlaneCore::ConfigItem.new(key: :output_directory,
                                      env_name: "OUTPUT_DIRECTORY",
                                      description: "Directory for output",
                                      optional: true),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end

      def self.version_string(version_name, build_number)
          return "#{version_name} (#{build_number})";
      end

      def self.version_short_string(version_name, build_number)
          return "v#{version_name}_b#{build_number}";
      end

      def self.get_ios_app_info(ipa_file)
        info = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(ipa_file)

        app_info = {}
        app_info[:build_no] = info['CFBundleVersion']
        app_info[:bundle_id] = info['CFBundleIdentifier']
        app_info[:version] = info['CFBundleShortVersionString']
        app_info[:name] = CGI.escapeHTML(info['CFBundleName'])

        return app_info
      end

      def self.get_android_app_info(apk_file)
        require 'apktools/apkxml'

        # Load the XML data
        parser = ApkXml.new(apk_file)
        parser.parse_xml("AndroidManifest.xml", false, true)

        elements = parser.xml_elements

        versionCode = nil
        versionName = nil
        packageName = nil
        name = nil

        elements.each do |element|
          if element.name == "manifest"
            element.attributes.each do |attr|
              if attr.name == "versionCode"
                versionCode = attr.value
              elsif attr.name == "versionName"
                versionName = attr.value
              elsif attr.name == "package"
                packageName = attr.value
              end
            end
          elsif element.name == "application"
            element.attributes.each do |attr|
              if attr.name == "label"
                name = attr.value
              end
            end
          end
        end

        if versionCode =~ /^0x[0-9A-Fa-f]+$/ #if is hex
          versionCode = versionCode.to_i(16)
        end

        app_info = {}
        app_info[:build_no] = versionCode
        app_info[:bundle_id] = packageName
        app_info[:version] = versionName
        app_info[:name] = name
      end
    end
  end
end
