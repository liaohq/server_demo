#!/bin/bash  
  
# 指定要遍历的目录，这里使用当前目录"."  
dir="."  
  
# 使用find命令查找所有.proto文件，并调用basename和cut命令来截取文件名  
find "$dir" -type f -name "*.proto" | while read -r filepath; do  
    # 使用basename命令获取文件名部分，然后使用cut命令去除后缀  
    filename=$(basename "$filepath")  
    filename_without_extension="${filename%.*}"  
      
    # 输出截取后的文件名  
    echo "$filename, $filename_without_extension"  
      
    # 在这里可以添加其他操作，比如使用protoc编译等  
     protoc --descriptor_set_out "$filename_without_extension.pb" "$filename" 
done





