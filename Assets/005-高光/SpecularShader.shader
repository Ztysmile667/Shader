// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//高光 = （入射光颜色和强度  ·   高光反射系数）max(0，视角方向·反射方向)的系数次方
//反射方向可以由表面法线和光源方向计算而得
//reflect（i,n）-->i，入射方向，n法线方向，求得的是反射方向
Shader "MyShader/SpecularShader"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;


			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};
			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 color : COLOR0;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize( UnityObjectToWorldNormal(v.normal));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0 * _Diffuse.rbg * saturate(dot(worldNormal, worldLightDir));


				//反射光
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//_WorldSpaceCameraPos世界空间中相机的位置 - 世界空间的顶点位置 得到 世界空间下的视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);
				fixed3 specular = _LightColor0 * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
				
				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				return fixed4(i.color, 1);
			}

			ENDCG
		}
	}
}
