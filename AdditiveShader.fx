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

struct VertexShaderInput
{
    float4 Position : POSITION0;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float2 vPos     : TEXCOORD1;  // Передаем vPos через TEXCOORD1 вместо VPOS
};

VertexShaderOutput MainVS(VertexShaderInput input)
{
    VertexShaderOutput output;
    output.Position = input.Position;
    output.Color = input.Color;
    output.TexCoord = input.TexCoord;
    // Вычисляем vPos в вершинном шейдере
    output.vPos = input.Position.xy * float2(0.5, -0.5) + float2(0.5, 0.5);
    output.vPos *= screenSizeInPixels;
    return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float2 screenUV = input.vPos / screenSizeInPixels;
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
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader  = compile PS_SHADERMODEL MainPS();
    }
}
