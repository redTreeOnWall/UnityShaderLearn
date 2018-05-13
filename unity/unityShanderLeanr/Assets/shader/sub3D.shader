Shader "lee/sub"
{

	Properties   
	    {  
			_waterLightColor("水波颜色",Color) =(1,1,1)
			_waterNormal ("水流法线贴图", 2D) = "white" {}  
			_waterSpeedX ("水流1速度x",float ) = 0.02
			_waterSpeedY ("水流1速度y",float ) = 0.005
			_water2SpeedX ("水流2速度x",float ) = 0.01
			_water2SpeedY ("水流2速度y",float ) = 0.03
			_lightVec("太阳光方向",Vector)  =(0.3,0.28,0.43,1)
	    }  
	  
	SubShader  {
		// Tags { "RenderType" = "Opaque" }  
		Tags { 
			"Queue"="Transparent"
		}  
		CGPROGRAM
		#pragma surface surf SimpleLight alpha

		// half4 LightingSimpleLight (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)   
		half4 LightingSimpleLight (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)   
        {  
            half4 c;  
            // half3 h = normalize (lightDir + viewDir);  
  
            // half diff = max (0, dot (s.Normal, lightDir));  
  
            // float nh = max (0, dot (s.Normal, h));  
            // float spec = pow (nh, 48.0);  
  
            // c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);  
            // c.a = s.Alpha;  

			c.rgb = s.Albedo;

            c.a = s.Alpha;  

            return c;  
        }  

		struct Input{
			float4 color :COLOR;
			float2 uv_waterNormal;
		};

		float _waterSpeedX;
		float _waterSpeedY;
		float _water2SpeedX;
		float _water2SpeedY;
		sampler2D _waterNormal;
		float4 _lightVec;
		float4 _waterLightColor;
		// Vector _lightVec;

		void surf (Input IN ,inout SurfaceOutput o){
			
			float2 uv1 = IN.uv_waterNormal;
			uv1 =uv1 +  float2(_waterSpeedX * _Time.y,_waterSpeedY * _Time.y);
			float2 uv2 = IN.uv_waterNormal;
			uv2 =uv2 +  float2(_water2SpeedX * _Time.y,_water2SpeedY * _Time.y);
			half4 water1 =  tex2D(_waterNormal,uv1);
			half4 water2  = tex2D(_waterNormal,uv2);

			float3 n1 =UnpackNormal(water1);
			float3 n2 =UnpackNormal(water2);

			//将两个法线混合
			float3 nMult = n1 + n2;

			//太阳光方向
			float3 sunDir  = fixed3(_lightVec.x,_lightVec.y,_lightVec.z);
			
			float emmis = dot(nMult,sunDir);

			// half4 waterLast  = water1 - water2;


			//  o.Albedo = float3(n.x,n.y,n.z);
			//  o.Albedo = float3 (emmis,emmis,emmis);
			 o.Albedo = _waterLightColor.rgb;
			 //浸湿，取比较亮的部分作为波纹；
            o.Alpha =9 *  saturate(emmis-0.9);
			//o.Albedo = waterLast.rgb;
			// o.Normal=UnpackNormal(water1);
			//o.Normal=n;

		}
		ENDCG
	}
}