Shader "MyShader/DiffuseShader"
{
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
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
		
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
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
				//获得Unity的内置变量得到环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//世界空间的法线信息
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				//光源方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//_LightColor0访问该Pass处理的光源颜色和强度信息
				//saturate可以把参数截取到[0,1]的范围内
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal, worldLight));
				o.color = ambient + diffuse;
				return o;
				
			}
			
			fixed4 frag(v2f i) :SV_Target
			{
				return fixed4(i.color, 1);
			}


			ENDCG
		}
	}
	Fallback "Diffuse"
}
