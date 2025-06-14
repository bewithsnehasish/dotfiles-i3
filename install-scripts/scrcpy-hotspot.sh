#!/bin/bash
adb connect 192.168.133.80:5555
scrcpy --video-codec=h265 -m 1024 --max-fps=60 --no-audio -K

