describe Fastlane::Actions::GenerateHtmlAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The generate_html plugin is working!")

      Fastlane::Actions::GenerateHtmlAction.run(nil)
    end
  end
end
