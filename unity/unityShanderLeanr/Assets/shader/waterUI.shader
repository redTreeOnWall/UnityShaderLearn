Shader "Lee/UI/water"
{
	Properties   
	    {  
			_waterLightColor("水波颜色",Color) =(1,1,1)
			_waterNormal ("水流法线贴图", 2D) = "white" {}  
			_waterTille("水波平铺比例",float) =1
			_waterArea2d ("水流影响区域", 2D) = "white" {}  
			_waterSpeedX ("水流1速度x",float ) = 0.02
			_waterSpeedY ("水流1速度y",float ) = 0.005
			_water2SpeedX ("水流2速度x",float ) = 0.01
			_water2SpeedY ("水流2速度y",float ) = 0.03
			_lightVec("太阳光方向",Vector)  =(0.3,0.28,0.43,1)
	    }  
	  

    SubShader
    {
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
		Cull Off
        Lighting Off
        ZWrite Off
        Fog{ Mode Off }
        Blend SrcAlpha One
        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma alpha multi_compile __ UNITY_UI_ALPHACLIP
            
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                half2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };
            
			float _waterSpeedX;
			float _waterSpeedY;
			float _water2SpeedX;
			float _water2SpeedY;
			sampler2D _waterNormal;
			sampler2D _waterArea2d;
			float _waterTille;
			float4 _lightVec;
			float4 _waterLightColor;

            v2f vert(appdata_t IN)
            {
				v2f OUT;
                OUT.worldPosition = IN.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = IN.texcoord;
                // OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _waterNormal);
                #ifdef UNITY_HALF_TEXEL_OFFSET
                OUT.vertex.xy += (_ScreenParams.zw-1.0) * float2(-1,1) * OUT.vertex.w;
                #endif
                
                return OUT;
            }


            float4 frag(v2f IN) : SV_Target
            {

				float2 uv1 = IN.texcoord /_waterTille;
				uv1 =uv1 +  float2(_waterSpeedX * _Time.y,_waterSpeedY * _Time.y);
				float2 uv2 = IN.texcoord/_waterTille;
				uv2 =uv2 +  float2(_water2SpeedX * _Time.y,_water2SpeedY * _Time.y);
				half4 water1 =  tex2D(_waterNormal,uv1);
				half4 water2  = tex2D(_waterNormal,uv2);

				float3 n1 =UnpackNormal(water1);
				float3 n2 =UnpackNormal(water2);

				//将两个法线混合
				float3 nMult = n1 + n2;

				//太阳光方向
				float3 sunDir  = fixed3(_lightVec.x,_lightVec.y,_lightVec.z);

				//水流受影响区域
				float4 waterArea = tex2D(_waterArea2d , IN.texcoord);
			
				float emmis = dot(nMult,sunDir) -1 + waterArea.x;
				
				float3 waterColor = _waterLightColor.rgb;

				float waterAlpha = 9 *  saturate(emmis-0.9);

                return float4(waterColor.x,waterColor.y,waterColor.z,waterAlpha);  
                // return float4(,1,1,0.1);  
            }
        ENDCG
        }
    }
}
