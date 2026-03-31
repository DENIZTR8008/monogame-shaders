#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

// All constants are hardcoded (no uniforms in this shader)
// ps_c0 = (1.0, 0.15625, 1.15625, 6.4)

Texture2D SpriteTexture;
sampler2D SpriteTextureSampler = sampler_state { Texture = <SpriteTexture>; };

Texture2D transMap;
sampler2D transMapSampler = sampler_state { Texture = <transMap>; };

struct VertexShaderOutput
{
    float4 Position : SV_POSITION;
    float4 Color    : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float4 c0 = float4(1.0, 0.15625, 1.15625, 6.4);

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
    result.w   = outAlpha;
    return result;
}

technique Technique1
{
    pass Pass1
    {
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
}
