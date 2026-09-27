"""Capture public artwork screens using an already installed development app."""
import argparse
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('--adb', default='adb')
parser.add_argument('--screen', choices=['checklist', 'office'], default='checklist')
args = parser.parse_args()

def shell(*parts):
    return subprocess.check_output([args.adb, 'shell', *parts], text=True)

def tap(label):
    for _ in range(8):
        shell('uiautomator', 'dump', '/sdcard/window.xml')
        tree = ET.fromstring(shell('cat', '/sdcard/window.xml'))
        matches = [node for node in tree.iter('node')
                   if node.get('content-desc') == label and node.get('clickable') == 'true']
        if matches:
            box = list(map(int, re.findall(r'\d+', matches[0].get('bounds'))))
            shell('input', 'tap', str((box[0]+box[2])//2), str((box[1]+box[3])//2))
            time.sleep(2)
            return
        shell('input', 'swipe', '550', '1700', '550', '850', '300')
        time.sleep(.5)
    raise AssertionError('Missing control: ' + label)

shell('am', 'force-stop', 'mv.zamzam.flutter')
shell('am', 'start', '-n', 'mv.zamzam.flutter/.MainActivity')
time.sleep(5)
tap('ޗެކްލިސްޓް' if args.screen == 'checklist' else 'އޮފީސް')
output = Path('artifacts') / args.screen / 'android'
output.mkdir(parents=True, exist_ok=True)
for page in range(1, 5 if args.screen == 'checklist' else 2):
    (output / f'page-{page}.png').write_bytes(subprocess.check_output([args.adb, 'exec-out', 'screencap', '-p']))
    if args.screen == 'checklist':
        shell('input', 'swipe', '850', '1000', '160', '1000', '350')
        time.sleep(1)
shell('input', 'keyevent', '4')
time.sleep(.5)
shell('uiautomator', 'dump', '/sdcard/window.xml')
assert 'ޗެކްލިސްޓް' in shell('cat', '/sdcard/window.xml'), 'Back must restore Home'
print(args.screen + ': captured artwork and verified Back')
