# futurevoices

This quark is the codebase for the installation "Future Voices / Zukunftsmusik" by the Society for Nontrivial Pursuits, created for ctm festival 2021, Kontinuum. 
It generates a continuous live stream of voice contributions. 

You can listen and contribute to it at: https://futurevoices.radio/

## Installery
1. SC [download](https://supercollider.github.io/download)
 (And OSX only: watch out for quarantine)
2. move to Applications
3. move SuperCollider.app outside of its folder, next to it,
 into `/Applications`, so that it is
	`/Applications/SuperCollider/
	/Applications/SuperCollider.app`
4. in Terminal, delete app quarantine attribute:
`xattr -d com.apple.quarantine /Applications/SuperCollider.app`
should answer:
`xattr: /Applications/SuperCollider.app: No such xattr: com.apple.quarantine`

## Get Quarks working (Class Extensions)

May need to [install](https://git-scm.com/) git for your platform.

Paste this code into SC:
```bash
Quarks.fetchDirectory
// should find this url
Quarks.findQuarkURL("adclib");

Quarks.directory.size ; // 276!

// try a single install:
Quarks.install("JITLibExtensions");

// gui should see 270 or so quarks
Quarks.gui

/// install all the quarks FuVo needs:
[ "JITLibExtensions", "adclib", "SafetyNet", "HyperDisCo", "DayTimer", "postlog", "Bjorklund", "Vowel", "ContextSnake", "Morse" ].do { |name| Quarks.install(name) };



/// if you cannot get Quarks to work,
/// install the copied quarks_packaged folder instead:

Quarks.install("~/Seafile/Future_Voices/quarks_packaged");


// run this patch to load entire setup (select all code text and shift-enter):
"~/Seafile/Future_Voices/code-work/_fullLoad.scd".openOS;

```
