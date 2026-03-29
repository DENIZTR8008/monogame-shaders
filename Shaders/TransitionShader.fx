// Transition/Wipe Shader for MonoGame Android

#if OPENGL
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

matrix WorldViewProjection;
texture Texture;
texture TransitionTexture;
sampler TextureSampler = sampler_state
{
    Texture = <Texture>;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

sampler TransitionSampler = sampler_state
{
    Texture = <TransitionTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

float Progress; // 0.0 to 1.0
float4 Color = float4(0.0, 0.0, 0.0, 1.0);
int Mode = 0; // 0: Fade, 1: Wipe, 2: Circle, 3: Texture-based

struct VertexShaderInput
{
    float4 Position : POSITION0;
    float4 Color : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
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

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float4 texColor = tex2D(TextureSampler, input.TexCoord) * input.Color;

    if (Mode == 0)
    {
        // Simple fade to color
        return lerp(texColor, Color, Progress);
    }
    else if (Mode == 1)
    {
        // Horizontal wipe
        float mask = step(Progress, input.TexCoord.x);
        return lerp(texColor, Color, mask);
    }
    else if (Mode == 2)
    {
        // Circle expand
        float2 center = float2(0.5, 0.5);
        float dist = distance(input.TexCoord, center) * 2.0;
        float mask = step(Progress, 1.0 - dist);
        return lerp(Color, texColor, mask);
    }
    else if (Mode == 3)
    {
        // Texture-based transition
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
