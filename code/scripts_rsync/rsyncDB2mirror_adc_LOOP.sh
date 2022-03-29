## sync 
while true; do
rsync -arvz -e 'ssh -p 2222' adc@gencomp.medienhaus.udk-berlin.de:/home/vinzenz/zukunftsmusik.radio/node/uploads/ ~/Seafile/future_mirror/;
sleep 300;
done
