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
        
        if(_rtmpSession->GetConnectedFlag() != 0){
            if (0 != _rtmpSession->IsConnected()) {
                _rtmpSession->DisConnect();
            }
            if (_rtmpSession) {
                delete _rtmpSession;
            }
        }
    }
    
    int LibRtmpSessionMgr::getConnectFlag(){
        return _rtmpSession->GetConnectedFlag();
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
        
        if ((0 == _rtmpSession->IsConnected()) && (0 != _rtmpSession->GetConnectedFlag())){
            _rtmpSession->SetConnectedFlag(FALSE);
            m_jobQueue.enqueue([=]() {
                int iFlag = 0;
                while (!_iEndFlag) {
                    if (0 == _rtmpSession->IsConnected()) {
                        _rtmpSession->Connect();
                    }
                    if (0 != _rtmpSession->IsConnected()) {
                        m_callback(*this, kClientStateSessionStarted);
                        break;
                    }else{
                        if (0 == iFlag) {
                            m_callback(*this, kClientStateHandshake0);
                        }
                        iFlag = 1;
                        for (int iLoop=0; iLoop < 100; iLoop++) {
                            if (_iEndFlag) {
                                break;
                            }
                            usleep(10);
                        }
                    }
                }
            });
            return;
        }
        
        if ((0 == _rtmpSession->IsConnected()) || (0 == _rtmpSession->GetConnectedFlag())){
            return;
        }
        std::shared_ptr<Buffer> buf = std::make_shared<Buffer>(size);
        buf->put(const_cast<uint8_t*>(data), size);
        
        m_jobQueue.enqueue([=]() {
            if(_iEndFlag){
                return;
            }
            if((RTMP_PT_AUDIO != uiMsgTypeId) && (RTMP_PT_VIDEO !=  uiMsgTypeId)){
                return;
            }
            unsigned char* pSendData = NULL;
            buf->read(&pSendData, size);
            int iRet = 0;
            if(RTMP_PT_AUDIO == uiMsgTypeId){
                if (0 != _rtmpSession->IsConnected()) {
                    //printf("SendAudioRawData...\r\n");
                    iRet = _rtmpSession->SendAudioRawData(pSendData, (int)size, (unsigned int)ts);
                    //printf("SendAudioRawData return %d\r\n", iRet);
                }
            }else if (RTMP_PT_VIDEO ==  uiMsgTypeId){
                if (0 != _rtmpSession->IsConnected()) {
                    //printf("SendVideoRawData...\r\n");
                    iRet = _rtmpSession->SendVideoRawData(pSendData, (int)size, (unsigned int)ts);
                    //printf("SendVideoRawData return %d\r\n", iRet);
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
            int iFlag = 0;
            while (!_iEndFlag) {
                if (0 == _rtmpSession->IsConnected()) {
                    _rtmpSession->Connect();
                }
                if (0 != _rtmpSession->IsConnected()) {
                    m_callback(*this, kClientStateSessionStarted);
                    break;
                }else{
                    if (0 == iFlag) {
                        m_callback(*this, kClientStateHandshake0);
                    }
                    iFlag = 1;
                    for (int iLoop=0; iLoop < 100; iLoop++) {
                        if (_iEndFlag) {
                            break;
                        }
                        usleep(10);
                    }
                }
            }
        });
    }
    
    void LibRtmpSessionMgr::setBandwidthCallback(BandwidthCallback callback){
        
    }
}