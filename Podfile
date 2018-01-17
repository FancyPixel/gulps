source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'Gulps' do

  pod 'RealmSwift', '~> 3.1.0'
  pod 'AMWaveTransition', '~> 0.5'
  pod 'AHKActionSheet', '~> 0.5'
  pod 'pop', '~> 1.0'
  pod 'AMPopTip', '~> 3.1.1'
  pod 'UICountingLabel', '~> 1.2'
  pod 'CVCalendar', '~> 1.6.0'
  pod 'BAFluidView', '~> 0.2.3'
  pod 'BubbleTransition', '~> 2.0.0'

  target 'GulpsTests' do
    inherit! :search_paths
    pod 'Nimble', '~> 7.0.3'
    pod 'Quick', '~> 1.2.0'
    pod 'Nimble-Snapshots', '~> 6.3.0'
    pod 'FBSnapshotTestCase', '2.1.4'
  end
end

target 'GulpsToday' do
  pod 'RealmSwift', '~> 3.1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
