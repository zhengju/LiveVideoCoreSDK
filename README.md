# LiveVideoCoreSDK 
基于IOS的手机视频直播SDK.
============================
LiveVideoCoreSDK是基于IOS的视频直播SDK(支持IOS8.1以上,基于开源videocore进行了改进)
-----------------------------------------------------------------------------
分辨率,速率配对关系:<br/>
1, 720x1280:至少1.5mbps;<br/>
2, 540x960: 至少800kbps;<br/>
3, 360x640: 至少:600kbps;<br/>
 
如果想获取丰富的滤镜直播效果，并且免除编译整合的困难, 可以到我新的基于gpuimage的代码库:<br/>
1, 多滤镜IOS推流SDK:<br/>
基于GPUImage的多滤镜拍摄, 滤镜资源丰富. [https://github.com/runner365/GPUImageRtmpPush] (https://github.com/runner365/GPUImageRtmpPush)<br/>
2, Android rtmp拍摄直播SDK:<br/>
Android手机软编码，手机适配能力强，支持所有市面的RTMP服务器。
[https://github.com/runner365/android_rtmppush_sdk] (https://github.com/runner365/android_rtmppush_sdk)<br/>
<br/>
RTMP推荐开源服务器:
----------------------
NGINX-RTMP: 基于NGINX的rtmp服务模块，需要结合nginx来进行编译. [https://github.com/arut/nginx-rtmp-module] (https://github.com/arut/nginx-rtmp-module)<br/>
SRS(simple rtmp server): 国产独立的RTMP服务， [https://github.com/ossrs/srs] (https://github.com/ossrs/srs)<br/>

