// Transition Shader for MonoGame Android - FIXED
#if OPENGL
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float4x4 WorldViewProjection;
texture Texture : register(s0);
texture TransitionTexture : register(s1);
sampler TextureSampler = sampler_state
{
    Texture = <Texture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler TransitionSampler = sampler_state
{
    Texture = <TransitionTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

float Progress;
float4 Color;
int Mode;

struct VertexShaderInput
{
    float4 Position : POSITION0;
    float4 Color : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct VertexShaderOutput
{
    float4 Position : POSITION0;
    float4 Color : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

VertexShaderOutput MainVS(VertexShaderInput input)
{
    VertexShaderOutput output;
    output.Position = mul(input.Position, WorldViewProjection);
    output.Color = input.Color;
    output.TexCoord = input.TexCoord;
    return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR0
{
    float4 texColor = tex2D(TextureSampler, input.TexCoord) * input.Color;

    if (Mode == 0)
    {
        return lerp(texColor, Color, Progress);
    }
    else if (Mode == 1)
    {
        float mask = step(Progress, input.TexCoord.x);
        return lerp(texColor, Color, mask);
    }
    else if (Mode == 2)
    {
        float2 center = float2(0.5, 0.5);
        float dist = distance(input.TexCoord, center) * 2.0;
        float mask = step(Progress, 1.0 - dist);
        return lerp(Color, texColor, mask);
    }
    else if (Mode == 3)
    {
        float4 transColor = tex2D(TransitionSampler, input.TexCoord);
        float mask = step(transColor.r, Progress);
        return lerp(texColor, Color, mask);
    }

    return texColor;
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}
