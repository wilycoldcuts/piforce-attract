import os, collections, signal, sys, subprocess, socket
import triforcetools
from time import sleep

logfile = open('log.txt', 'w')             # open input file

triforcetools.connect('192.168.0.2', 10703)
logfile.write("Sending..."+sys.argv[1])
triforcetools.HOST_SetMode(0, 1)
triforcetools.SECURITY_SetKeycode("\x00" * 8)
triforcetools.DIMM_UploadFile(sys.argv[1])
logfile.write("Transfer\nComplete!")
triforcetools.HOST_Restart()
while True:
    triforcetools.TIME_SetLimit(10*60*1000)
    sleep(5)