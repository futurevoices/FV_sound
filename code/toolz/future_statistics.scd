q.updateEntries
q.mainDict.size

q.mainDict.sum(_.dur) / q.mainDict.size; // avg 8.8 sec!

//// 82 soundfiles sind stereo?? why???
q.mainDict.select { |d| d.soundfile.numChannels > 1 }.size;

q.mainDict.select { |d| d.soundfile.numChannels > 1 }.collect(_.dur).asArray.sort.plot

10000 / 90 // 1 deg sind 111 km
10000 / 90 / 100 // 0.1 deg = 11 km, 0.01 deg = 1.1km



/// how many are moved already?
"/Users/adc/Seafile/Future_Voices/upload/contributions/*UPLOADED*".pathMatch.size
"/Users/adc/Seafile/Future_Voices/upload/contributions/*.yaml".pathMatch.size

/// not movable wit upload page error:
... shoreh
marcel .. 01
marcel .. 02
