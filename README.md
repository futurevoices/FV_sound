# FutureVoices
This quark is the codebase for the installation "Future Voices / Zukunftsmusik" by the Society for Nontrivial Pursuits, created for ctm festival 2021, Kontinuum. 
It generates a continuous live stream of voice contributions. 

You can listen and contribute to it at: https://futurevoices.radio/

### Chapters

- [FutureVoices](#futurevoices)
  * [Installery](#installery)
  * [Get Quarks working (Class Extensions)](#get-quarks-working--class-extensions-)
  * [Troubleshooting](#troubleshooting)
    + [ERROR: duplicate Class found: 'XYZ'](#error--duplicate-class-found---xyz-)
    + [MacOS: xattr com.apple.quarantine SuperCollider.app/](#macos--xattr-comapplequarantine-supercolliderapp-)

## Installing
### 1- SC [download](https://supercollider.github.io/download)
-  OSX only: watch out for quarantine
	1. move to Applications
	2. move SuperCollider.app outside of its folder, next to it,
	 into `/Applications`, so that it is
		`/Applications/SuperCollider/
		/Applications/SuperCollider.app`
	3. in Terminal, delete app quarantine attribute:
		`xattr -d com.apple.quarantine /Applications/SuperCollider.app`
		should answer:
		`xattr: /Applications/SuperCollider.app: No such xattr: com.apple.quarantine`

### 2- Get Quarks working (Class Extensions)

You need git; may need to [install](https://git-scm.com/) it for your platform.


Paste this code into SC:
```
Quarks.fetchDirectory;
// should find this url
Quarks.findQuarkURL("adclib");

Quarks.directory.size; // 276!

// try a single install:
Quarks.install("JITLibExtensions");

// check on gui:
Quarks.gui;
// should see 270 or so quarks; close it again

/// install all the quarks FuVo needs, by executing this line of code:
[ "JITLibExtensions", "adclib", "SafetyNet", "HyperDisCo", "DayTimer", "postlog", "Bjorklund", "Vowel", "ContextSnake", "Morse", "StartupFile" ].do { |name| Quarks.install(name) };


// ALTERNATIVE: if you cannot get Quarks to work (e.g. no git installed),
// install the copied quarks_packaged folder instead:
Quarks.install("~/Seafile/Future_Voices/quarks_packaged");
// fix paths for github
```

### 3- RUN
```
// run this patch to load entire setup (select all code text and shift-enter):
"~/Seafile/Future_Voices/code-work/_fullLoad.scd".openOS; // fix paths for github
```

## Troubleshooting

### ERROR: duplicate Class found: 'XYZ'
What probably happened: You also activated the `fallback` Quarks into SuperCollider which are not necessary if the get loaded from the root.

Go to `Preferences` ->  `Interpreter` -> Remove the `.../Seafile/Future_Voices/...` from the list.

### MacOS: xattr com.apple.quarantine SuperCollider.app/ 
`q.codeDir = thisProcess.nowExecutingPath.dirname;`
If this line is erroring on MacOS.

Go to the terminal and run `xattr SuperCollider.app/`. If it returns `com.apple.quarantine`, then run `xattr -d SuperCollider.app/`. Then it should work.

Make sure SuperCollider is also inside the Applications folder. Not in the SuperCollider Subfolder.

### SampleRate is up to 16k or mismatching in general
While using bluetooth headphones, SuperCollider might be having problems with mismatching sampling rates. To use your computers speakers run the following:

`s.options.inDevice = "MacBook Pro Microphone";`
`s.options.outDevice = "MacBook Pro Speakers";`

The strings have to be replaced with your computers device names. Find them by running `ServerOptions.devices.cs`.
