#!/bin/bash
# Author: Shengjie.Liu
# Date: 2018-10-15
# Version: 1.0
# Description: Hades内存和流量测试


# 获取命令行输入参数
component=$1
# 包名
packagename=$(echo $1 | cut -d"/" -f1)
echo "Package name is '$packagename'"
# 活动名
activityname=$(echo $1 | cut -d"/" -f2)
echo "Activity name is '$activityname'"
# UID
userid=$(adb shell dumpsys package $packagename | grep userId= | sed 's/ //g' | tr -d $'\r' | cut -c 8-12)
echo "uid = $userid"

# create dir output
mkdir output_memory
# get current path
WORKSPACE=`pwd`
# put results to OUTPUT
OUTPUT=${WORKSPACE}/output_memory

# launch application
adb shell am start -n $component
sleep 3s

# back to home
for ((i = 1; i <= 5; i = i + 1))
do
	adb shell input keyevent 4
done

# 获取流量
tcprcv1=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
tcpsnd1=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
data1=`echo "($tcprcv1+$tcpsnd1)" | bc`

# 获取内存值
adb shell dumpsys meminfo $packagename > $OUTPUT/meminfo1.txt

echo "请在两分钟内触发Hades广告！"

sleep 120s

echo "时间到，停止操作！"

tcprcv2=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
tcpsnd2=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
data2=`echo "($tcprcv2+$tcpsnd2)" | bc`

adb shell dumpsys meminfo $packagename > $OUTPUT/meminfo2.txt

echo "请等待5分钟！"

sleep 300s

tcprcv3=$(adb shell cat /proc/uid_stat/$userid/tcp_rcv | sed 's/ //g' | tr -d $'\r')
tcpsnd3=$(adb shell cat /proc/uid_stat/$userid/tcp_snd | sed 's/ //g' | tr -d $'\r')
data3=`echo "($tcprcv3+$tcpsnd3)" | bc`

adb shell dumpsys meminfo $packagename > $OUTPUT/meminfo3.txt

echo "流量消耗：$data1 $data2 $data3"
echo "脚本运行结束！"


