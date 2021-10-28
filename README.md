# iDRAC-6-Console-Launch-Script
launch idrac 6 with jre (no changing security settings)

this builds on a script i found from user @xbb and a comment from user @ready4droid

tested on windows 10 and requests ADMIN

i have added a urc promt for admin privalages as it wouldnt run for me without (because its launching jave i think)

i have also added a promt for the kvm port set as not every one uses the default 5900

this also cleans up the files after the idrac window is closed (the .lib dir and the .jar file created)

this works for me with java jre 1.7.80 just exstract the jre folder from the .tar and place in the root folder the .bat is in
