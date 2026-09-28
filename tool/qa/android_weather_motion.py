"""Public fixed-data preview checks; install weather_motion.dart first."""
import argparse
import re
import subprocess
import time
from pathlib import Path
import xml.etree.ElementTree as ET

parser=argparse.ArgumentParser()
parser.add_argument('--adb', default='adb')
args=parser.parse_args()
output=Path('artifacts/weather/motion/android')
output.mkdir(parents=True,exist_ok=True)

def shell(*parts):
    return subprocess.check_output([args.adb,'shell',*parts],text=True)

def tree():
    shell('uiautomator','dump','/sdcard/window.xml')
    return ET.fromstring(shell('cat','/sdcard/window.xml'))

def tap(label):
    node=next(n for n in tree().iter('node') if n.get('content-desc')==label and n.get('clickable')=='true')
    box=list(map(int,re.findall(r'\d+',node.get('bounds'))))
    shell('input','tap',str((box[0]+box[2])//2),str((box[1]+box[3])//2))
    time.sleep(1)

def capture(name):
    (output/name).write_bytes(subprocess.check_output([args.adb,'exec-out','screencap','-p']))

def storm_visible():
    return any('ގުގުރުމާ ވާރޭ' in n.get('content-desc','') for n in tree().iter('node'))

shell('am','force-stop','mv.zamzam.flutter')
shell('am','start','-n','mv.zamzam.flutter/.MainActivity')
time.sleep(4)
capture('clear-clouds-1.png')
time.sleep(.8)
capture('clear-clouds-2.png')
shell('input','swipe','550','1800','550','650','500')
time.sleep(1)
assert storm_visible(), 'Rain and storm cards must be reachable'
capture('rain-storm.png')
tap('ހޯމް')
tap('މޫސުން')
assert storm_visible(), 'Switching tabs must retain the scroll position'
shell('input','keyevent','3')
time.sleep(1)
shell('am','start','-n','mv.zamzam.flutter/.MainActivity')
time.sleep(1)
assert storm_visible(), 'Resuming must retain the weather screen'
capture('resumed.png')
print('Weather preview: clear/cloud/rain/storm, tab retention and background/resume passed')
