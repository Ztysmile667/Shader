Shader "MyShader/OneTextureShader"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
		SubShader
		{
			Tags { "LightMode" = "ForwardBase" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;//定义纹理需要多加个这个
				fixed4 _Specular;
				float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				//把顶点从模型空间转化到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//把顶点从模型空间转到世界空间，为了在片元中处理一些数据
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				//_MainTex_ST.zw是贴图的偏移，xy是缩放，
				//先对纹理坐标进行缩放在进行偏移
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				//世界空间中从该点到光源的光照方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//材质的反射率
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//LightColor0是场景中的灯光的颜色
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				//世界空间中从该点到相机的观察方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//Blinn-Phong模型中：引入的新矢量h  h^ = normalize(v^+I^);  I^：光源的单位矢量   v^：视角方向
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				fixed3 col = ambient + diffuse + specular;
				return fixed4(col,1);
			}
			ENDCG
		}
	}
}
