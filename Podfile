source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

def common_pods
#  pod 'Realm', '~> 0.92'
  pod 'AMWaveTransition', '~> 0.5'
  pod 'AHKActionSheet', '~> 0.5'
  pod 'pop', '~> 1.0'
  pod 'AMPopTip', '~> 0.7'
  pod 'UICountingLabel', '~> 1.2'
  pod 'JTCalendar', git: 'https://github.com/andreamazz/JTCalendar', branch: 'develop'
  pod 'BAFluidView', git: 'https://github.com/antiguab/BAFluidView', branch: '0.1.5'
  pod 'BubbleTransition'
#  pod 'BEMSimpleLineGraph'
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

# target 'GulpsToday' do
#   pod 'Realm', '~> 0.92'
# end

# target 'Gulps WatchKit Extension' do
#   pod 'Realm', '~> 0.92'
# end

inhibit_all_warnings!
use_frameworks!

