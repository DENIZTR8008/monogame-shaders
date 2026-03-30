// Dither Shader for MonoGame Android - FIXED
#if OPENGL
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float4x4 WorldViewProjection;
texture Texture : register(s0);
sampler TextureSampler = sampler_state
{
    Texture = <Texture>;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = Point;
    AddressU = Clamp;
    AddressV = Clamp;
};

float DitherScale;
float4 Color1;
float4 Color2;

static const float DitherMatrix[16] = {
    0.0, 8.0, 2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0, 9.0,
    15.0, 7.0, 13.0, 5.0
};

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
    float4 ScreenPos : TEXCOORD1;
};

VertexShaderOutput MainVS(VertexShaderInput input)
{
    VertexShaderOutput output;
    output.Position = mul(input.Position, WorldViewProjection);
    output.Color = input.Color;
    output.TexCoord = input.TexCoord;
    output.ScreenPos = output.Position;
    return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR0
{
    float4 texColor = tex2D(TextureSampler, input.TexCoord) * input.Color;

    float2 screenCoord = input.ScreenPos.xy / input.ScreenPos.w;
    float2 pixelCoord = screenCoord * DitherScale;

    int x = int(abs(pixelCoord.x)) % 4;
    int y = int(abs(pixelCoord.y)) % 4;
    int index = y * 4 + x;

    float threshold = DitherMatrix[index] / 16.0;
    float gray = dot(texColor.rgb, float3(0.299, 0.587, 0.114));

    float4 result = gray > threshold ? Color1 : Color2;
    result.a = texColor.a;

    return result;
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile VS_SHADERMODEL MainVS();
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}
