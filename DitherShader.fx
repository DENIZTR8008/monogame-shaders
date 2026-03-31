#if OPENGL
    #define SV_POSITION POSITION
    #define VS_SHADERMODEL vs_3_0
    #define PS_SHADERMODEL ps_3_0
#else
    #define VS_SHADERMODEL vs_4_0_level_9_1
    #define PS_SHADERMODEL ps_4_0_level_9_1
#endif

float2 ditherSize;
float2 screenSize;
float  scale;
float  flipYPos;

Texture2D SpriteTexture;
sampler2D SpriteTextureSampler = sampler_state { Texture = <SpriteTexture>; };

Texture2D ditherTex;
sampler2D ditherTexSampler = sampler_state { Texture = <ditherTex>; };

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
    float2 vPos     : TEXCOORD1;
};

VertexShaderOutput MainVS(VertexShaderInput input)
{
    VertexShaderOutput output;
    output.Position = input.Position;
    output.Color = input.Color;
    output.TexCoord = input.TexCoord;
    output.vPos = input.Position.xy * float2(0.5, -0.5) + float2(0.5, 0.5);
    output.vPos *= screenSize;
    return output;
}

// frac для HLSL, fract для GLSL - используем условное определение
#if OPENGL
    #define FRACT fract
#else
    #define FRACT frac
#endif

float4 MainPS(VertexShaderOutput input) : COLOR
{
    // Защита от нулевых параметров (MojoShader баг!)
    float2 _ditherSize = ditherSize;
    float2 _screenSize = screenSize;
    float  _scale = scale;
    float  _flipYPos = flipYPos;

    if (_ditherSize.x < 1.0) _ditherSize = float2(4.0, 4.0);
    if (_screenSize.x < 1.0) _screenSize = float2(1280.0, 720.0);
    if (_scale < 0.001) _scale = 1.0;
    if (_flipYPos < 0.0 || _flipYPos > 1.0) _flipYPos = 0.0;

    const float c4x = 0.5;
    const float c4y = 50.0;
    const float c4z = 0.02;
    const float c4w = -1.1;
    const float c5x = 0.1;
    const float c5y = 1.0;
    const float c5z = 0.0;

    float2 fragCoord = input.vPos;

    // lerp работает везде, не меняем!
    float flippedY = lerp(fragCoord.y, _screenSize.y - fragCoord.y, _flipYPos);
    float2 r1xy = float2(fragCoord.x, flippedY);

    float invScaleX = 1.0 / _scale;
    float2 r0yz = r1xy * invScaleX;

    float r0x = (_screenSize.y * invScaleX) + c4y;
    float2 r1xy2 = FRACT(r0yz);
    r0yz = r0yz - r1xy2 + c4x;

    float2 invDither = float2(1.0 / _ditherSize.x, 1.0 / _ditherSize.y);
    float2 r1zw = r0yz * invDither;
    float2 r2xy = FRACT(r1zw);
    r1zw = r1zw - r2xy;
    float2 r0yw = (-_ditherSize * r1zw) + r0yz;

    r0x = (input.Color.a * -r0x) + r0yz.y;
    r0x = (r0x + c4y) * c4z;
    float r1z = max(-r0x, c4w);
    r0x = min(r1z, c5x);

    float2 ditherUV = r1xy2 * r0yw;
    float4 r1 = tex2D(ditherTexSampler, ditherUV);
    r0x = r0x + r1.x;

    float outAlpha = (r0x >= 0.0) ? c5y : c5z;

    float4 sprite = tex2D(SpriteTextureSampler, input.TexCoord);

    float4 result;
    result.xyz = sprite.xyz * input.Color.rgb;
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
