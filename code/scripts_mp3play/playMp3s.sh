cd  ~/Seafile/Future_Voices/soundlibs/test ; while true; do ls *.wav | while read fileName; do afplay "$fileName" ; done; sleep 0.1; done
