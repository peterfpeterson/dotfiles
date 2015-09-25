#!/bin/sh
PLISTBUDDY=/usr/libexec/PlistBuddy
TERM_PLIST=~/Library/Preferences/com.apple.Terminal.plist
${PLISTBUDDY} ${TERM_PLIST} -c "Set \"Window Settings\":Basic:Bell false"
${PLISTBUDDY} ${TERM_PLIST} -c "Set \"Window Settings\":Basic:CommandString bash"
${PLISTBUDDY} ${TERM_PLIST} -c "Set \"Window Settings\":Basic:RunCommandAsShell true"
${PLISTBUDDY} ${TERM_PLIST} -c "Set \"Window Settings\":Basic:shellExitAction 1"
${PLISTBUDDY} ${TERM_PLIST} -c "Set \"Window Settings\":Basic:useOptionAsMetaKey true"

