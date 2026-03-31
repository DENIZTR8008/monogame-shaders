#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float2 screenSizeInPixels;

Texture2D baseMask;
sampler2D baseMaskSampler = sampler_state { Texture = <baseMask>; };

Texture2D SpriteTexture;
sampler2D SpriteTextureSampler = sampler_state { Texture = <SpriteTexture>; };

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input, float2 vPos : VPOS) : COLOR
{
    float2 screenUV = vPos / screenSizeInPixels;
    float4 s1 = tex2D(baseMaskSampler, screenUV);

    // Sample s0 (sprite texture)
    float4 s0 = tex2D(SpriteTextureSampler, input.TexCoord);

    // Additive blend, clamped to 1.0
    float4 result;
    result.xyz = min(s1.xyz + s0.xyz, 1.0);
    result.w   = s1.w;

    return result * input.Color;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}
