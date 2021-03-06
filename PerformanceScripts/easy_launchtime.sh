#!/usr/bin/env bash
# Author: Shengjie.Liu
# Date: 2019-04-09
# Version: 3.2
# Description: 启动时间脚本
# How to use: run script and follow the instruction that print in the terminal.
# changelog: 专项适配sony8.0手机

# parameter: apk_address
function install() {
  adb install ${1}
  sleep 5s
  adb shell input keyevent 3
}

# parameter: package_name
function uninstall() {
  adb uninstall ${1}
  sleep 2s
}

# parameter: component
function getStartupTime() {
  adb shell am start -W  ${1} | grep  -i Total | sed 's/ //g' | tr -d $'\r' | cut -d":" -f 2
  sleep 2s
}

# parameter: package_name
function clearApp() {
  adb shell am force-stop ${1}
#  adb shell pm clear ${1}
  sleep 10s
}

function quitApp() {
  adb shell input keyevent 4
  adb shell input keyevent 4
  adb shell input keyevent 4
  sleep 2s
}

# click "OK" when installed application showing permission dialog
function clickOk() {
  sleep 2s
  adb shell input tap 973 1713
}

read -p "请输入APK地址：" apk_address

# get packageName and acvitiyName via aapt
launch_activity=$(aapt dump badging ${apk_address} | grep launchable-activity | sed 's/ //g' | tr -d $'\r' | cut -d"'" -f2)
package_name=$(aapt dump badging ${apk_address} | grep package: | sed 's/ //g' | tr -d $'\r' | cut -d"'" -f2)
if [[ ! -n "$launch_activity" ]]; then
	echo "Sorry, here is not have information about launchable-activity."
	read -p "Please input the packageName and activityName：" component
	package_name=$(echo ${component} | cut -d"/" -f1)
    echo "Package name is '${package_name}'"
else
    component="${package_name}/${launch_activity}"
    echo "PackageName&ActivityName: ${component}"
fi

echo "Starting launch time test..."

# first installation time
install ${apk_address}
clickOk
starttime1=`getStartupTime ${component}`
uninstall ${package_name}

install ${apk_address}
clickOk
starttime2=`getStartupTime ${component}`
uninstall ${package_name}

install ${apk_address}
clickOk
starttime3=`getStartupTime ${component}`
sleep 20s

echo "首次安装时间（ms）：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# The first installation time test is over, beginning warm boot test
quitApp

# warm boot
starttime1=`getStartupTime ${component}`
quitApp

starttime2=`getStartupTime ${component}`
quitApp

starttime3=`getStartupTime ${component}`
quitApp

echo "热启动时间（ms）：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# cold boot
clearApp ${package_name}
starttime1=`getStartupTime ${component}`

clearApp ${package_name}
starttime2=`getStartupTime ${component}`

clearApp ${package_name}
starttime3=`getStartupTime ${component}`

echo "冷启动时间（ms）：$starttime1 $starttime2 $starttime3"
echo "($starttime1+$starttime2+$starttime3)/3" | bc

# back to zero
uninstall ${package_name}
