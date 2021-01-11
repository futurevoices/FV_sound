// all of them:
Quarks.installed.do(_.update);

// just fuvo quark
Quarks.installed.detect { |qrk| qrk.name == "futurevoices" }.update;

