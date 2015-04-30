desc "Run the test suite"

task :test do
  build = "xcodebuild \
    -workspace Gulps.xcworkspace \
    -scheme Gulps \
    -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6,OS=8.3'"
  system "#{build} test | xcpretty --test --color"  
end

task :default => :test

