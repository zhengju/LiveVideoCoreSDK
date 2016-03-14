//
//  LibRtmpSession.cpp
//  Pods
//
//  Created by Alex.Shi on 16/3/9.
//
//

#include "LibRtmpSessionMgr.hpp"
#include "LibRtmpSession.hpp"

namespace videocore
{
    LibRtmpSessionMgr::LibRtmpSessionMgr(std::string uri, LibRTMPSessionStateCallback callback):m_callback(callback)
    ,_rtmpSession(NULL)
    ,m_jobQueue("com.videocore.librtmp")
    ,_iEndFlag(0)
    {
        memset(_szRtmpUrl, 0, sizeof(_szRtmpUrl));
        strcpy(_szRtmpUrl, uri.c_str());
        
        _rtmpSession = new LibRtmpSession(_szRtmpUrl);
    }
    
    LibRtmpSessionMgr::~LibRtmpSessionMgr(){
        _iEndFlag = 1;
        m_jobQueue.mark_exiting();
        m_jobQueue.enqueue_sync([]() {});
        if (0 != _rtmpSession->IsConnected()) {
            _rtmpSession->DisConnect();
        }
        if (_rtmpSession) {
            delete _rtmpSession;
        }
    }
    
    void LibRtmpSessionMgr::pushBuffer(const uint8_t* const data, size_t size, IMetadata& metadata){
        if(_iEndFlag){
            return;
        }
        const LibRTMPMetadata_t inMetadata = static_cast<const LibRTMPMetadata_t&>(metadata);
        
        uint64_t ts = inMetadata.getData<kLibRTMPMetadataTimestamp>() ;
//        const int streamId = inMetadata.getData<kLibRTMPMetadataMsgStreamId>();
//        unsigned int uiDataLength = inMetadata.getData<kLibRTMPMetadataMsgLength>();
        unsigned int uiMsgTypeId  = inMetadata.getData<kLibRTMPMetadataMsgTypeId>();
        unsigned char* pSendBuff  = (unsigned char*)malloc(size);
        memcpy(pSendBuff, data, size);
        
        m_jobQueue.enqueue([=]() {
            if(_iEndFlag){
                return;
            }
            if (0 == _rtmpSession->IsConnected()) {//当前是断线状态
                _rtmpSession->Connect();//尝试连接
                if (0 != _rtmpSession->IsConnected()) {//连接成功，上报连接状态
                    m_callback(*this, kClientStateSessionStarted);
                }
            }
            
            if (0 != _rtmpSession->GetConnectedFlag()) {//当前是连接状态
                if (0 == _rtmpSession->IsConnected()) {//上报离线状态
                    m_callback(*this, kClientStateNotConnected);
                }
            }
            
            if(RTMP_PT_AUDIO == uiMsgTypeId){
                if (0 != _rtmpSession->IsConnected()) {
                    _rtmpSession->SendAudioRawData((unsigned char*)pSendBuff, (int)size, (unsigned int)ts);
                    free(pSendBuff);
                }
            }else if (RTMP_PT_VIDEO ==  uiMsgTypeId){
                if (0 != _rtmpSession->IsConnected()) {
                    _rtmpSession->SendVideoRawData((unsigned char*)pSendBuff, (int)size, (unsigned int)ts);
                    free(pSendBuff);
                }
            }
            

        });
    }
    
    void LibRtmpSessionMgr::setSessionParameters(IMetadata& parameters){
        LibRTMPSessionParameters_t& parms = dynamic_cast<LibRTMPSessionParameters_t&>(parameters);
        _bitRate = parms.getData<kLibRTMPSessionParameterVideoBitrate>();
        _frameDuration = parms.getData<kLibRTMPSessionParameterFrameDuration>();
        _frameHeight = parms.getData<kLibRTMPSessionParameterHeight>();
        _frameWidth = parms.getData<kLibRTMPSessionParameterWidth>();
        _audioSampleRate = parms.getData<kLibRTMPSessionParameterAudioFrequency>();
        _audioStereo = parms.getData<kLibRTMPSessionParameterStereo>() ? 2 : 1;
        
        m_jobQueue.enqueue([=]() {
            if (0 == _rtmpSession->IsConnected()) {
                _rtmpSession->Connect();
            }
            if (0 != _rtmpSession->IsConnected()) {
                m_callback(*this, kClientStateSessionStarted);
            }
        });
    }
    
    void LibRtmpSessionMgr::setBandwidthCallback(BandwidthCallback callback){
        
    }
}