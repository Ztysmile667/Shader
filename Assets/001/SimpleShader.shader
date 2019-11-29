
Shader "MyShader/SimpleShader"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert//vert函数包含了顶点着色器代码，下面一样
			#pragma fragment frag

			struct a2v 
			{
				float4 vertex:POSITION;//跟下头POSITION的注释相同
				float3 normal:NORMAL;//NORMAL告诉UNITY，用模型空间的法线方向填充normal
				float4 texcoord:TEXCOORD0;//用模型的第一套纹理坐标填充变量
			};

			//通过POSITION告诉UNITY把模型中的顶点坐标填充到v中
			//SV_POSITION告诉UNITY顶点着色器的输出是裁剪控件中的顶点坐标
			//a代表应用 v代表顶点着色器，a2v的意思就是把数据从应用阶段传递到顶点着色器中
			float4 vert(/*float4 v:POSITION*/a2v v) :SV_POSITION
			{
				return UnityObjectToClipPos(v.vertex);
			}
			//SV_Target告诉渲染器，把用户的输出颜色存储到一个渲染目标中
			fixed4 frag() : SV_Target{
				return fixed4(1.0,1.0,1.0,1.0);
			}
			ENDCG
		}
	}
}
