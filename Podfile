source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

def common_pods
  pod 'RealmSwift', '~> 3.0.2'
  pod 'AMWaveTransition', '~> 0.5'
  pod 'AHKActionSheet', '~> 0.5'
  pod 'pop', '~> 1.0'
  pod 'AMPopTip', '~> 3.1.1'
  pod 'UICountingLabel', '~> 1.2'
  pod 'JTCalendar', '~> 2.2.1'
  pod 'BAFluidView', '~> 0.2.3'
  pod 'BubbleTransition', '~> 2.0.0'
end

target 'Gulps' do
  common_pods
end

target 'GulpsToday' do
  pod 'RealmSwift'
end

target 'GulpsTests' do
  common_pods
  pod 'Nimble', '~> 7.0.3'
  pod 'Quick', '~> 1.2.0'
  pod 'Nimble-Snapshots', '~> 6.3.0'
  pod 'FBSnapshotTestCase', '2.1.4'
end

inhibit_all_warnings!
use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
