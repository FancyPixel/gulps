require 'plist'

if ARGV.size < 1 
  puts "Use: #{$0} your.bundle.name"
  exit
end

plist = Plist::parse_xml('Gulps WatchKit App/Info.plist')
plist['CFBundleIdentifier'] = "#{ARGV[0]}.watchkitapp"
plist['WKCompanionAppBundleIdentifier'] = ARGV[0]
plist.save_plist('Gulps WatchKit App/Info.plist')

plist = Plist::parse_xml('Gulps WatchKit Extension/Gulps WatchKit Extension.entitlements')
plist['com.apple.security.application-groups'] = [ ARGV[0] ]
plist.save_plist('Gulps WatchKit Extension/Gulps WatchKit Extension.entitlements')

plist = Plist::parse_xml('Gulps/Gulps.entitlements')
plist['com.apple.security.application-groups'] = [ ARGV[0] ]
plist.save_plist('Gulps/Gulps.entitlements')

plist = Plist::parse_xml('GulpsToday/GulpsToday.entitlements')
plist['com.apple.security.application-groups'] = [ ARGV[0] ]
plist.save_plist('GulpsToday/GulpsToday.entitlements')

plist = Plist::parse_xml('Gulps/Info.plist')
plist['CFBundleIdentifier'] = ARGV[0]
plist.save_plist('Gulps/Info.plist')

plist = Plist::parse_xml('GulpsToday/Info.plist')
plist['CFBundleIdentifier'] = "#{ARGV[0]}.$(PRODUCT_NAME:rfc1034identifier)"
plist.save_plist('GulpsToday/Info.plist')

plist = Plist::parse_xml('Gulps WatchKit Extension/Info.plist')
plist['CFBundleIdentifier'] = "#{ARGV[0]}.watchkitextension"
plist['NSExtension']['NSExtensionAttributes']['WKAppBundleIdentifier'] = "#{ARGV[0]}.watchkitapp"
plist.save_plist('Gulps WatchKit Extension/Info.plist')

plist = Plist::parse_xml('GulpsTests/Info.plist')
plist['CFBundleIdentifier'] = ARGV[0]
plist.save_plist('GulpsTests/Info.plist')

