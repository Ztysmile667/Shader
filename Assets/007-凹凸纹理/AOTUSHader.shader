Shader "MyShader/AOTUSHader"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0//凹凸尺寸
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"


			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;//定义纹理需要多加个这个
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//副切线：向量和切线的叉积是垂直于这个平面的一个向量，最后乘以tangent.w确定了选取哪个方向\
				//#define TANGENT_SPACE_ROTATION \
				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; \
				//由切线空间中切线，法线，副切线构成的三维矩阵\
				float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal )
				TANGENT_SPACE_ROTATION;
				//得到模型空间下的光照和视角方向，利用rotation转换到切线空间
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLigthDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				//利用tex2D对——BumpMap进行采样
				fixed4 packedNormal = tex2D(_BumpMap, i.uv. zw);
				fixed3 tangentNormal;
				//如果我们没有在UNity中吧图片设为NormalMap，就需要加上下面两行代码\
				tangentNormal.xy = (packenNormal.xy*2-1)*_BumpScale;\
				tangentNormal.z = aqrt(1.0- saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				
				//使用UnPackNormal得到正确的法线方向 normal = color * 2 - 1
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				//z = sqrt(1 - (x * x + y * y))
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLigthDir));

				fixed3 halfDir = normalize(tangentLigthDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}
	}
}
