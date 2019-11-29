Shader "MyShader/AlphaBlend"
{
	Properties{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}
		SubShader
		{
			//IgnoreProjector:这个Shader不会受到投影器（Projectors）的影响
			//RenderType：可以让Unity吧这个Shader归入到提前定义的组，以指明这个Shader是一个使用了透读测试的Shader
			Tags{"Queue" = "Transparent"  "IgnoreProjector" = "True"  "RenderType" = "Transparent"}
			//添加这个pass的目的是把模型的深度信息写入深度缓冲中，从而剔除模型中被自身遮挡的片元。
			//ColorMask用于设置颜色通道的掩码：当为0时，意味着该Pass不写入任何颜色通道，即不会输出任何颜色
			Pass{
				Zwrite On
				ColorMask 0
				}
			Pass{
					Tags{"LightMode" = "ForwardBase"}
					ZWrite Off
					Blend SrcAlpha OneMinusSrcAlpha
					CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "Lighting.cginc"

					fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					fixed _AlphaScale;

					struct a2v {
						float4 vertex:POSITION;
						float3 normal:NORMAL;
						float4 texcoord:TEXCOORD0;
					};
					struct v2f {
						float4 pos:SV_POSITION;
						float3 worldNormal:TEXCOORD0;
						float3 worldPos:TEXCOORD1;
						float2 uv:TEXCOORD2;
					};

					v2f vert(a2v v) {
						v2f o;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.worldNormal = UnityObjectToWorldNormal(v.normal);
						o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
						o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
						return o;
					}

					fixed4 frag(v2f i) :SV_Target{
						fixed3 worldNormal = normalize(i.worldNormal);
						fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
						fixed4 texColor = tex2D(_MainTex, i.uv);

						fixed3 albedo = texColor.rgb * _Color.rgb;
						fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
						fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
						return fixed4(diffuse + ambient, _AlphaScale*texColor.a);
					}
					ENDCG
				}
		}
			Fallback "Transparent/Cutout/VertexLit"
}
