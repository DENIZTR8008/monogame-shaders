#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

// ps_c0 = ditherSize (xy)
// ps_c1 = screenSize, c1.y = screenHeight
// ps_c2 = scale (x)
// ps_c3 = flipYPos (x): 0 = normal Y, 1 = flip Y
float2 ditherSize;
float2 screenSize;
float  scale;
float  flipYPos;

Texture2D SpriteTexture;
sampler2D SpriteTextureSampler = sampler_state { Texture = <SpriteTexture>; };

Texture2D ditherTex;
sampler2D ditherTexSampler = sampler_state { Texture = <ditherTex>; };

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input, float2 vPos : VPOS) : COLOR
{
    const float4 c4 = float4(0.5, 50.0, 0.02, -1.1);
    const float4 c5 = float4(0.1, 1.0, 0.0, 0.0);

    float4 r0, r1, r2;

    r0.x = screenSize.y - vPos.y;
    r1.y = lerp(vPos.y, r0.x, flipYPos);
    r1.x = vPos.x;
    r0.x = 1.0 / scale;
    r0.y = r0.x * r1.x;
    r0.z = r0.x * r1.y;
    r1.y = c4.y;
    r0.x = (screenSize.y * r0.x) + r1.y;
    r1.x = frac(r0.y);
    r1.y = frac(r0.z);
    r0.y = r0.y - r1.x;
    r0.z = r0.z - r1.y;
    r0.y = r0.y + c4.x;
    r0.z = r0.z + c4.x;
    r1.x = 1.0 / ditherSize.x;
    r1.y = 1.0 / ditherSize.y;
    r1.z = r0.y * r1.x;
    r1.w = r0.z * r1.y;
    r2.x = frac(r1.z);
    r2.y = frac(r1.w);
    r1.z = r1.z - r2.x;
    r1.w = r1.w - r2.y;
    r0.y = (-ditherSize.x * r1.z) + r0.y;
    r0.w = (-ditherSize.y * r1.w) + r0.z;
    r0.x = (input.Color.a * -r0.x) + r0.z;
    r0.x = r0.x + c4.y;
    r0.x = r0.x * c4.z;
    r1.z = max(-r0.x, c4.w);
    r0.x = min(r1.z, c5.x);
    r0.y = r1.x * r0.y;
    r0.z = r1.y * r0.w;
    r1 = tex2D(ditherTexSampler, float2(r0.y, r0.z));
    r0.x = r0.x + r1.x;
    float outA = (r0.x >= 0.0) ? c5.y : c5.z;
    r0 = tex2D(SpriteTextureSampler, input.TexCoord);
    return float4(r0.xyz * input.Color.rgb, outA);
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}
