#!/bin/bash

if [ ! -d "temp" ]; then
    mkdir temp;
fi

if [ ! -d "data" ]; then
    mkdir data;
fi

cd temp;
echo "正在下載原始資料...";
wget -O temp.html https://setiathome.berkeley.edu/cpu_list.php 2> /dev/null;

echo "正在處理檔案...";
# 刪除所有換行
tr -d "\n" < temp.html > temp
# 僅取得 table 部分
grep -oE "<table.+><\/table>" temp > temp2
# 增加換行，以便接下來的替換
sed -i 's/<tr>/\n<tr>/g' temp2
# 取得資料
sed -E -i 's/<tr><td>(.+?)<\/td><td>(.+?)<\/td><td>(.+?)<\/td><td>(.+?)<\/td><td>(.+?)<\/td><\/tr>/"\1": [\2, \3, \4, \5],/g' temp2
# 頭
sed -i '1,2d' temp2
sed -i '1s/^/{\n/' temp2
# 尾
sed -i '$d' temp2
sed -i '$s/,$//' temp2
echo "}" >> temp2

datetime=$(date +%y%m%d_%H%M%S);
mv temp2 ../data/${datetime}.json;
rm -f temp*;

cd ../data;

if [ ! -f "alldata.json" ]; then
    mv $datetime.json alldata.json;
    echo "已建立檔案 data/alldata.json";
    exit 0;
else
    # 未完成
    exit 1;
fi