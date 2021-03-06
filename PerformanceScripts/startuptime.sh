#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-12-26
# Version: 3.0
# Description: 启动时间脚本
# How to use: run script and follow the instruction that print in the terminal.

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

read -p "请输入APK地址：" apk_address
read -p "请输入包名和活动名：" component
# Package name
package_name=$(echo ${component} | cut -d"/" -f1)
echo "Package name is '${package_name}'"

# first installation time
install ${apk_address}
starttime1=`getStartupTime ${component}`
uninstall ${package_name}

install ${apk_address}
starttime2=`getStartupTime ${component}`
uninstall ${package_name}

install ${apk_address}
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
