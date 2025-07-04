#!/usr/bin/env bash
env _JAVA_AWT_WM_NONREPARENTING=1 _JAVA_OPTIONS="-Dsun.java2d.uiScale=2" DISPLAY=:0 ghidra
