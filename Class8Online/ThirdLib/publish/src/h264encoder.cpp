
#include "h264encoder.h"
#include <string.h>
#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>


#define BASE_TIME 1000000

NSMutableData *videoData = [[NSMutableData alloc]init];
NSMutableData *videoData_YUV = [[NSMutableData alloc]init];

int videoCount = 0;
CH264Encoder::CH264Encoder()
{
	m_iDesVideoWidth  = 0;
	m_iDesVideoHeight = 0;
	
	m_szNalBuffer   = NULL;
	m_p264Nal       = NULL;
	m_p264Param     = NULL;
	m_p264Pic       = NULL;
	m_p264Handle    = NULL;
    memset(m_szPPS,0,1024);
    memset(m_szSPS,0,1024);
    m_nPPSSize = 0;
    m_nSPSSize = 0;

}


CH264Encoder::CH264Encoder(int nVideoW,int nVideoH,int nBit,int nFps)
{
	
	m_iDesVideoWidth  = 0;
	m_iDesVideoHeight = 0;
	
	m_szNalBuffer   = NULL;
	m_p264Nal       = NULL;
	m_p264Param     = NULL;
	m_p264Pic       = NULL;
	m_p264Handle    = NULL;

	m_iDesVideoWidth = nVideoW;
	m_iDesVideoHeight = nVideoH;
	m_nBit = nBit;
	m_nFps = nFps;


}

CH264Encoder::~CH264Encoder()
{
	h264_EncodeUninit();
}

void CH264Encoder::h264_SetParam(int nVideoW,int nVideoH,int nBit,int nFps)
{
	m_iDesVideoWidth = nVideoW;
	m_iDesVideoHeight = nVideoH;
	m_nBit = nBit;
	m_nFps = nFps;

}

void CH264Encoder::h264_ReConfig(int nVideoW,int nVideoH,int nBit,int nFps)
{
	if(m_p264Param == NULL || m_p264Handle == NULL)
		return ;
	bool bIsChang = false;
	if(m_iDesVideoWidth != nVideoW || m_iDesVideoHeight != nVideoW)
	{
		m_iDesVideoWidth = nVideoW;
		m_iDesVideoHeight = nVideoH;
		m_p264Param->i_width   = m_iDesVideoWidth;   //set frame width   
		m_p264Param->i_height  = m_iDesVideoHeight;  //set frame height  
		bIsChang = true;
	}
	if(m_nBit != nBit)
	{
		m_nBit = nBit;
		m_p264Param->rc.i_bitrate  = m_nBit;  
		m_p264Param->rc.i_vbv_max_bitrate = m_nBit * 1.2;
		bIsChang = true;
	}

	if(m_nFps != nFps)
	{
		m_nFps = nFps;
		int nFpsNum = m_nFps;
		int nFpsDen = 1;
		if(m_nFps < 100)
		{
			nFpsNum = BASE_TIME * m_nFps;
			nFpsDen = nFpsDen * BASE_TIME;
		}
		m_p264Param->i_fps_num     = nFpsNum;  
		m_p264Param->i_fps_den     = nFpsDen;
		m_p264Param->i_keyint_max = m_nFps;  
		bIsChang = true;
	}
	if(bIsChang)
	{
		x264_encoder_reconfig(m_p264Handle,m_p264Param);
	}
}

bool CH264Encoder::h264_EncodeInit(int nSrcW,int nSrcH)
{
	m_szNalBuffer = new unsigned char[DATA_SIZE]; 
	memset(m_szNalBuffer,0,DATA_SIZE);  
	 
	 
	m_p264Param   = new x264_param_t();  
	m_p264Pic     = new x264_picture_t();  
	memset(m_p264Pic,0,sizeof(x264_picture_t)); 

	x264_param_default(m_p264Param);  //set default param   
	x264_param_default_preset(m_p264Param,"veryfast", "zerolatency");
    x264_param_apply_profile(m_p264Param, x264_profile_names[1]);
	//int err = x264_param_parse(m_p264Param,"preset","veryfast");
	m_p264Param->i_threads = 1;
	m_p264Param->i_width   = nSrcW;   //set frame width
	m_p264Param->i_height  = nSrcH;  //set frame height
	/*baseline level 1.1*/  
	//m_p264Param->b_cabac  = 0;
	//m_p264Param->i_bframe = 0;
	m_p264Param->b_interlaced  = 0;  
	m_p264Param->rc.i_rc_method= X264_RC_ABR;//X264_RC_CQP ;
	//m_p264Param->i_level_idc   = 21;
	m_p264Param->rc.i_bitrate  = m_nBit ;
	m_p264Param->rc.i_vbv_max_bitrate = m_nBit * 1.2;
   // m_p264Param->b_intra_refresh = 1;
  //  m_p264Param->b_annexb = 1;
    m_p264Param->b_deblocking_filter = 1;
    m_p264Param->b_cabac =1;
    m_p264Param->analyse.i_trellis = 0;
	// optimized h.264 paras
    // Author: Ray Zhang 20150309
	// Infor: level-6
	//m_p264Param->b_deblocking_filter = 1;
	//_p264Param->b_cabac = 1;
//	m_p264Param->analyse.intra = X264_ANALYSE_I4x4;
//	m_p264Param->analyse.inter = (X264_ANALYSE_PSUB8x8|X264_ANALYSE_I4x4);
//	//m_p264Param->analyse.i_me_method = ME_UMH;
//	m_p264Param->analyse.i_me_range = 20;
//	m_p264Param->analyse.i_subpel_refine = 2;
//	m_p264Param->i_frame_reference = 1;
//	m_p264Param->analyse.i_trellis = 0;
//	//m_p264Param->
//	m_p264Param->analyse.b_fast_pskip = 1;
//	m_p264Param->analyse.b_dct_decimate = 0;
    
	
	
	int nFpsNum = m_nFps;
	int nFpsDen = 1;
	if(m_nFps < 100)
	{
		nFpsNum = BASE_TIME * m_nFps;
		nFpsDen = nFpsDen * BASE_TIME;
	}
	//m_p264Param->i_fps_num     = nFpsNum;
	//m_p264Param->i_fps_den     = nFpsDen;
    m_p264Param->i_fps_num     = m_nFps;
    m_p264Param->i_fps_den     = 1;
    m_p264Param->i_keyint_max = m_nFps;
    m_p264Param->i_keyint_min = 6;
    x264_param_apply_profile(m_p264Param, "baseline");
    
	if((m_p264Handle = x264_encoder_open(m_p264Param)) == NULL)  
	{
		return false;  
    }
	x264_picture_alloc(m_p264Pic, X264_CSP_NV12, m_p264Param->i_width, m_p264Param->i_height);
	m_p264Pic->i_type = X264_TYPE_AUTO;
	
	//m_sws_context = sws_getContext(nSrcW, nSrcH, PIX_FMT_BGR24, m_iDesVideoWidth, m_iDesVideoHeight, //PIX_FMT_YUV420P, SWS_BILINEAR, NULL, NULL, NULL);
	   //Show AVOption  

	//def_ff_av_opt_set_int(m_sws_context,"src_range",0,0); 
	//def_ff_av_opt_set_int(m_sws_context,"dst_range",1,0);
	return true;
}

bool CH264Encoder::h264_EncodeUninit()
{
	if(m_p264Handle)
	{
		x264_encoder_close(m_p264Handle);
		m_p264Handle = NULL;
	}
	
	if(m_szNalBuffer)
	{
		delete [] m_szNalBuffer;
		m_szNalBuffer = NULL;
	}

	if(m_p264Param)
	{
		delete m_p264Param;
		m_p264Param = NULL;
	}

	if(m_p264Pic)
	{
		//x264_picture_clean(m_p264Pic);
		delete m_p264Pic;
		m_p264Pic = NULL;
	}
	return true;
}

bool CH264Encoder::h264_copyHeaderParam(unsigned char* pBuf,int &nSize)
{
	if(pBuf == NULL || m_p264Param == NULL)
		return false;

	char* szTmp = (char*)pBuf;

	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string(szTmp, "@setDataFrame" );  
	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string(szTmp, "onMetaData" );  
	szTmp=put_byte(szTmp, AMF_OBJECT );   
	szTmp=put_amf_string( szTmp, "author" );  
	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string( szTmp, "GT" );  
	szTmp=put_amf_string( szTmp, "copyright" );  
	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string( szTmp, "PWRD" );  
	szTmp=put_amf_string( szTmp, "presetname" );  
	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string( szTmp, "Custom" ); 
	szTmp=put_amf_string( szTmp, "width" );  
	szTmp=put_amf_double( szTmp, m_p264Param->i_width );  
	szTmp=put_amf_string( szTmp, "height" );  
	szTmp=put_amf_double( szTmp, m_p264Param->i_height );  
	szTmp=put_amf_string( szTmp, "framerate" );  
	szTmp=put_amf_double( szTmp, (double)m_p264Param->i_fps_num / m_p264Param->i_fps_den );  
	szTmp=put_amf_string( szTmp, "videocodecid" );  
	szTmp=put_byte(szTmp, AMF_STRING );  
	szTmp=put_amf_string( szTmp, "avc1" );  
	szTmp=put_amf_string( szTmp, "videodatarate" );  
	szTmp=put_amf_double( szTmp, m_p264Param->rc.i_bitrate );   
	szTmp=put_amf_string( szTmp, "avclevel" );  
	szTmp=put_amf_double( szTmp, m_p264Param->i_level_idc );   
	szTmp=put_amf_string( szTmp, "avcprofile" );  
	szTmp=put_amf_double( szTmp, 0x42 );   
	szTmp=put_amf_string( szTmp, "videokeyframe_frequency" );  
	szTmp=put_amf_double( szTmp, 3 );
	nSize = szTmp - (char*)pBuf;
	return true;
}
bool CH264Encoder::h264_CopyPPSandSPS(unsigned char* pBuf,int &nSize)
{
    if(m_nPPSSize <= 0 || m_nSPSSize <= 0)
        return false;
    
    char * szTemp = (char*)pBuf;
    
    short slen = m_nSPSSize;
    slen = htons(slen);
    memcpy(szTemp,&slen,sizeof(short));
    szTemp += sizeof(short);
    memcpy(szTemp, m_szSPS, m_nSPSSize);
    szTemp += m_nSPSSize;
    *szTemp = 0x01;
    szTemp += 1;
    slen = m_nPPSSize;
    slen = htons(slen);
    memcpy(szTemp,&slen,sizeof(short));
    szTemp += sizeof(short);
    memcpy(szTemp, m_szPPS, m_nPPSSize);
    szTemp += m_nPPSSize;
    nSize = szTemp - (char*)pBuf;
    
	/*bs_t bs={0};

	if(pBuf == NULL)
		return false;
    
	char * szTemp = (char*)pBuf;
    
	short slen=0;  
	bs_init(&bs,m_szNalBuffer,16);  
	
	if(m_p264Handle->sps->vui.i_num_units_in_tick < 100 && m_p264Handle->sps->vui.i_time_scale < 100)
	{
		m_p264Handle->sps->vui.i_num_units_in_tick = m_p264Handle->sps->vui.i_num_units_in_tick * 1000000;
		m_p264Handle->sps->vui.i_time_scale = m_p264Handle->sps->vui.i_time_scale * 1000000;
	}
     
	x264_sps_write(&bs, m_p264Handle->sps);//¶ÁÈ¡±àÂëÆ÷µÄSPS   
	//int nsize =  sizeof(x264_sps_t);
	slen=bs.p-bs.p_start+1;//spslen£¨short£©   
	slen=htons(slen);  
	memcpy(szTemp,&slen,sizeof(short));  
	szTemp+=sizeof(short);  
	*szTemp=0x67;  
	szTemp+=1;  
	memcpy(szTemp,bs.p_start,bs.p-bs.p_start);  
//	*(szTemp+11) = 0x03;
	szTemp+=bs.p-bs.p_start;  
	*szTemp=0x01;  
	szTemp+=1;  
	bs_init(&bs,m_szNalBuffer,DATA_SIZE);
	x264_pps_write(&bs, m_p264Handle->sps,m_p264Handle->pps);
	slen=bs.p-bs.p_start+1;  
	slen=htons(slen);  
	memcpy(szTemp,&slen,sizeof(short));  
	szTemp+=sizeof(short);  
	*szTemp=0x68;  
	szTemp+=1;  
	memcpy(szTemp,bs.p_start,bs.p-bs.p_start);  
	szTemp+=bs.p-bs.p_start; 
	nSize = szTemp - (char*)pBuf;*/
	return true;
}

bool CH264Encoder::h264_Encode(unsigned char* pDestBuf,unsigned int& nDestBufSize,unsigned char* pSRGBBuf,unsigned char * pDesBuf ,int nSrcW,int nSrcH)
{
	
	if(pDestBuf == NULL || pDesBuf == NULL)
		return false;

	unsigned  char * pNal = m_szNalBuffer;
    
    int nWidthStep = nSrcW * nSrcH;
    int nFrameSize = 0;
    m_p264Pic->img.i_plane = 2;
   // m_p264Pic->img.i_stride[0] = nWidthStep;
    //m_p264Pic->img.i_stride[1] = nWidthStep/4;
    //m_p264Pic->img.i_stride[2] = nWidthStep/4;
    m_p264Pic->img.plane[0] = pDesBuf;
    m_p264Pic->img.plane[1] = pDesBuf+nWidthStep;
   // m_p264Pic->img.plane[2] = pDesBuf+nWidthStep+nWidthStep/4;
   // memcpy(m_p264Pic->img.plane[0],pDesBuf,nWidthStep);
   // memcpy(m_p264Pic->img.plane[1],pDesBuf+nWidthStep,nWidthStep/4);
   // memcpy(m_p264Pic->img.plane[2],pDesBuf+nWidthStep+nWidthStep/4,nWidthStep/4);
    
    videoCount ++;
    
	if((nFrameSize = x264_encoder_encode(m_p264Handle, &m_p264Nal, &m_i264Nal, m_p264Pic ,&m_outPic)) < 0)
	{
		return false;
	}
    
    if(m_i264Nal <= 0)
        return false;
    
	for( int i = 0; i < m_i264Nal; i++ )
	{
        int i_size = 0;
		int i_data = DATA_SIZE;
        
        // x264_nal_encode(m_p264Handle, (uint8_t*)pNal, &m_p264Nal[i]);
        
      /*  if(m_p264Handle->nal_buffer_size < m_p264Nal[i].i_payload*3/2)
        {
            m_p264Handle->nal_buffer_size = m_p264Nal[i].i_payload * 2 + 4;
            if(m_p264Handle->nal_buffer_size > 0 )
                x264_free(m_p264Handle->nal_buffer);

            m_p264Handle->nal_buffer = (uint8_t*)x264_malloc(m_p264Handle->nal_buffer_size);
        }*/
        
       /*if (!videoData) {
            videoData = [[NSMutableData alloc]init];
        }
        printf("video:%d",videoCount);
        if (videoCount < 300) {
            UInt8 *pixeBuffer = (UInt8 *)m_p264Nal[i].p_payload;
            NSMutableData *writer1 = [[NSMutableData alloc] init];
            [writer1 appendBytes:pixeBuffer length:m_p264Nal[i].i_payload];
            [videoData appendData:writer1];
        }else if (videoCount == 300){
            NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [dirPaths objectAtIndex:0];
            NSString *savedPath = [docsDir stringByAppendingPathComponent:@"12000svideo"];
            BOOL savesuccess = [videoData writeToFile:savedPath atomically:YES];
            if (savesuccess) {
                printf("OK---------------------------");
            }
        }*/
    

        char* szData = (char*)m_p264Nal[i].p_payload;
        if(szData[0] == 0x00 && szData[1] == 0x00 && szData[2] == 0x01)
        {
            szData = (char*)m_p264Nal[i].p_payload+3;
            i_size = m_p264Nal[i].i_payload - 3;
        }
        else if(szData[0] == 0x00 && szData[1] == 0x00 && szData[2] == 0x00 && szData[3] == 0x01)
        {
            szData = (char*)m_p264Nal[i].p_payload+4;
            i_size = m_p264Nal[i].i_payload - 4;
        }
        
        if (szData[0]==0x65)
        {
            int n = 0;
        }
        
            
        if ((szData[0]&0x60)==0)
        {
            continue;
        }
            
        if (szData[0]==0x67)
        {
            if(m_nSPSSize <= 0)
            {
                memcpy(m_szSPS,szData,i_size);
                m_nSPSSize = i_size;
            }
            i_size = 0;
            continue;
        }
        if (szData[0]==0x68)
        {
            if(m_nPPSSize <= 0)
            {
                memcpy(m_szPPS,szData,i_size);
                m_nPPSSize = i_size;
            }
            i_size = 0;
            continue;
        }
            
        memmove(pNal,szData,i_size);
        pNal+=i_size;
	}

	unsigned int nSize=pNal-m_szNalBuffer;
    
    if(nSize  == 0)
        return false;
    
	if(nDestBufSize < nSize+9)
	{
		nDestBufSize = 0;
		return false;
	}

	if (m_i264Nal>1)  
	{  
		pDestBuf[0]=0x17;  
	}  
	else  
	{  
		pDestBuf[0]=0x27;  
	}  

	nDestBufSize =nSize + 9;  
	put_be32((char *)pDestBuf+5,nSize);  

	if(nSize > 0)
		memcpy(pDestBuf+9,m_szNalBuffer,nSize);
	return true;
}
