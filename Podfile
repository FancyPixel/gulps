source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

def common_pods
  pod 'AMWaveTransition', '~> 0.5'
  pod 'AHKActionSheet', '~> 0.5'
  pod 'pop', '~> 1.0'
  pod 'AMPopTip', '~> 0.7'
  pod 'UICountingLabel', '~> 1.2'
  pod 'JTCalendar', git: 'https://github.com/andreamazz/JTCalendar', branch: 'develop'
  pod 'BAFluidView', '~> 0.1.6'
  pod 'BubbleTransition'
end

target 'Gulps' do
  common_pods
end

target 'GulpsTests' do
  common_pods
  pod 'Nimble'
  pod 'Quick', '~> 0.3.1'
  pod 'Nimble-Snapshots'
end

inhibit_all_warnings!
use_frameworks!

