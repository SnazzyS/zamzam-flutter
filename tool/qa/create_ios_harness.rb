# Run with the Ruby/xcodeproj installation supplied by CocoaPods.
require 'xcodeproj'
require 'fileutils'
root = File.expand_path('../..', __dir__)
dir = File.join(root, 'artifacts', 'ios-harness')
FileUtils.mkdir_p(dir)
project = Xcodeproj::Project.new(File.join(dir, 'Parity.xcodeproj'))
target = project.new_target(:ui_test_bundle, 'ArtworkUITests', :ios, '17.0')
source = project.main_group.new_file(File.join(__dir__, 'ArtworkUITests.swift'))
target.source_build_phase.add_file_reference(source)
target.build_configurations.each do |config|
  config.build_settings.merge!({
    'PRODUCT_BUNDLE_IDENTIFIER' => 'mv.zamzam.parity.tests',
    'GENERATE_INFOPLIST_FILE' => 'YES',
    'SWIFT_VERSION' => '5.0',
    'CODE_SIGNING_ALLOWED' => 'NO',
    'TARGETED_DEVICE_FAMILY' => '1,2'
  })
end
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.add_test_target(target)
scheme.save_as(project.path, 'ArtworkUITests', true)
project.save
