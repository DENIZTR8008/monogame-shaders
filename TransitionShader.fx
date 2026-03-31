#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float4 transConstants;

Texture2D SpriteTexture;
sampler2D SpriteTextureSampler = sampler_state { Texture = <SpriteTexture>; };

Texture2D transMap;
sampler2D transMapSampler = sampler_state { Texture = <transMap>; };

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
};

VertexShaderOutput MainVS(VertexShaderInput input)
{
    VertexShaderOutput output;
    output.Position = input.Position;
    output.Color = input.Color;
    output.TexCoord = input.TexCoord;
    return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
    // Защита от нулевых констант (MojoShader баг!)
    float4 c0 = transConstants;
    if (c0.x == 0.0 && c0.y == 0.0 && c0.z == 0.0 && c0.w == 0.0)
        c0 = float4(1.0, 0.15625, 1.15625, 6.4);

    float4 r0 = tex2D(transMapSampler, input.TexCoord);
    float alpha = input.Color.a;

    r0.y = c0.x - alpha;
    r0.y = (r0.y * -c0.y) + alpha;

    float r1x = max(r0.x, r0.y);

    r0.x = c0.z * alpha;
    float r2x = min(r0.x, r1x);

    r0.x = -r0.y + r2x;
    float outAlpha = (r0.x * -c0.w) + c0.x;

    r0 = tex2D(SpriteTextureSampler, input.TexCoord);

    float4 result;
    result.xyz = r0.xyz * input.Color.rgb;
    result.w = outAlpha;
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
