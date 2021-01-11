// // did this already:
// Quarks.install("https://github.com/adcxyz/futurevoices");

Quarks.folder.openOS;

// update all of them:
Quarks.installed.do(_.update);

// update just fuvo quark
Quarks.installed.detect { |qrk| qrk.name == "futurevoices" }.update;

