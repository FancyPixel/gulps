desc "Run the test suite"

task :test do
  system "pod install"

  build = "xcodebuild \
    -workspace Gulps.xcworkspace \
    -scheme Gulps \
    -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.4'"
  system "#{build} test | xcpretty --test --color"  
end

task :default => :test

