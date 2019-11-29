Shader "MyShader/SimpleShader2"
{
	
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f
			{
				//pos里包含了顶点在裁剪空间中的位置信息
				float4 pos : SV_POSITION;
				//COLOR0语义可以用于存储颜色信息
				fixed3 color : COLOR0;
			};

			v2f vert(a2v v) 
			{
				//声明输出结构
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//v.normal包含了顶点的法线方向，其分量范围在[-1，1]
				//下面的代码把分量范围映射到了[0,1]
				//存储到o.color中传递给片元着色器
				o.color = v.normal * 0.5 +fixed3(0.5, 0.5, 0.5);
				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				return fixed4(i.color,1);
			}

			ENDCG
 		}
	}
}
