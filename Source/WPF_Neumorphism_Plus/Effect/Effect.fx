sampler2D Input             : register(S0);

float   OffsetX             : register(C0);
float   OffsetY             : register(C1);
float   BlurRadius          : register(C2);
float   SpreadRadius        : register(C3);
float4  PrimaryColor        : register(C4);
float4  SecondaryColor      : register(C5);
float   Inset               : register(C6);
float   RenderingMode       : register(C7);

float4  DdxDdy              : register(C8);

float profileFunc(float x)
{
    if (1 < x)
        return 0;

    if (x < 0)
        return 1;

    if (RenderingMode == 1)
        return 1 - x;
    else if (RenderingMode == 2)
        return (1 + cos(x * 3.1415926)) / 2;
    else
        return (1 + cos(x * 3.1415926)) / 2;
}

float3 adjustShadowRatio(float ratio1, float ratio2)
{
    float3 _return;
    float transparency = 1 * (1 - ratio1) * (1 - ratio2);

    _return.x = transparency;
    _return.y = (1 - transparency) * ratio1 / (ratio1 + ratio2);
    _return.z = (1 - transparency) * ratio2 / (ratio1 + ratio2);

    return _return;
}

///     | 1 | 2 | 3 |
///     | 4 | 5 | 6 |
///     | 7 | 8 | 9 |

float outerShadowCalculator(float2 uv :TEXCOORD, float OffsetDirection) : COLOR
{
    float OuterRatio_X = (abs(OffsetX) + BlurRadius + SpreadRadius) * length(DdxDdy.xy);
    float OuterRatio_Y = (abs(OffsetY) + BlurRadius + SpreadRadius) * length(DdxDdy.zw);

    float BlurEffectiveLengthX = 2 * BlurRadius * length(DdxDdy.xy);
    float BlurEffectiveLengthY = 2 * BlurRadius * length(DdxDdy.zw);
    float LengthConverterY2X = length(DdxDdy.xy) / length(DdxDdy.zw);

    float UnusedPaddingLeft;
    float UnusedPaddingRight;
    float UnusedPaddingTop;
    float UnusedPaddingBottom;

    if (OffsetX * OffsetDirection > 0)
    {
        UnusedPaddingLeft = 2 * OffsetX * OffsetDirection * length(DdxDdy.xy);
        UnusedPaddingRight = 1;
    }
    else
    {
        UnusedPaddingLeft = 0;
        UnusedPaddingRight = 1 + 2 * OffsetX * OffsetDirection * length(DdxDdy.xy);
    }

    if (OffsetY * OffsetDirection > 0)
    {
        UnusedPaddingTop = 2 * OffsetY * OffsetDirection * length(DdxDdy.zw);
        UnusedPaddingBottom = 1;
    }
    else
    {
        UnusedPaddingTop = 0;
        UnusedPaddingBottom = 1 + 2 * OffsetY * OffsetDirection * length(DdxDdy.zw);
    }

    float addRatio = 0;

    if ((uv.x < OuterRatio_X || (1 - OuterRatio_X) < uv.x || uv.y < OuterRatio_Y || (1 - OuterRatio_Y) < uv.y)
        &&
        UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingRight && UnusedPaddingTop < uv.y && uv.y < UnusedPaddingBottom)
    {
        // 1
        if (UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + BlurEffectiveLengthX
            &&
            UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + BlurEffectiveLengthY)
                addRatio = profileFunc(sqrt(pow(UnusedPaddingLeft + BlurEffectiveLengthX - uv.x, 2) + pow((UnusedPaddingTop + BlurEffectiveLengthY - uv.y) * LengthConverterY2X, 2)) / BlurEffectiveLengthX);
        // 2
        else if (UnusedPaddingLeft + BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight - BlurEffectiveLengthX
            &&
            UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + BlurEffectiveLengthY)
                addRatio = profileFunc((UnusedPaddingTop + BlurEffectiveLengthY - uv.y) / BlurEffectiveLengthY);
        // 3
        else if (UnusedPaddingRight - BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight
            &&
            UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + BlurEffectiveLengthY)
                addRatio = profileFunc(sqrt(pow(uv.x - (UnusedPaddingRight - BlurEffectiveLengthX), 2) + pow((UnusedPaddingTop + BlurEffectiveLengthY - uv.y) * LengthConverterY2X, 2)) / BlurEffectiveLengthX);
        // 4
        else if (UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + BlurEffectiveLengthX
            &&
            UnusedPaddingTop + BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom - BlurEffectiveLengthY)
                addRatio = profileFunc((UnusedPaddingLeft + BlurEffectiveLengthX - uv.x) / BlurEffectiveLengthX);
        // 5
        else if (UnusedPaddingLeft + BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight - BlurEffectiveLengthX
            &&
            UnusedPaddingTop + BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom - BlurEffectiveLengthY)
                addRatio = 1;
        // 6
        else if (UnusedPaddingRight - BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight
            &&
            UnusedPaddingTop + BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom - BlurEffectiveLengthY)
                addRatio = profileFunc((uv.x - (UnusedPaddingRight - BlurEffectiveLengthX)) / BlurEffectiveLengthX);
        // 7
        else if (UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + BlurEffectiveLengthX
            &&
            UnusedPaddingBottom - BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom)
                addRatio = profileFunc(sqrt(pow(UnusedPaddingLeft + BlurEffectiveLengthX - uv.x, 2) + pow((uv.y - (UnusedPaddingBottom - BlurEffectiveLengthY)) * LengthConverterY2X, 2)) / BlurEffectiveLengthX);
        // 8
        else if (UnusedPaddingLeft + BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight - BlurEffectiveLengthX
            &&
            UnusedPaddingBottom - BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom)
                addRatio = profileFunc((uv.y - (UnusedPaddingBottom - BlurEffectiveLengthY)) / BlurEffectiveLengthY);
        // 9
        else if (UnusedPaddingRight - BlurEffectiveLengthX < uv.x && uv.x < UnusedPaddingRight
            &&
            UnusedPaddingBottom - BlurEffectiveLengthY < uv.y && uv.y < UnusedPaddingBottom)
               addRatio = profileFunc(sqrt(pow(uv.x - (UnusedPaddingRight - BlurEffectiveLengthX), 2) + pow((uv.y - (UnusedPaddingBottom - BlurEffectiveLengthY)) * LengthConverterY2X, 2)) / BlurEffectiveLengthX);
    }

    return addRatio;
}

float4 main(float2 uv : TEXCOORD) : COLOR
{
    float4 color = tex2D(Input, uv);

    float addRatio_1 = outerShadowCalculator(uv, 1);
    float addRatio_2 = outerShadowCalculator(uv, -1);

    float3 adjustedRatio = adjustShadowRatio(addRatio_1, addRatio_2);

    return color * adjustedRatio.x + PrimaryColor * adjustedRatio.y + SecondaryColor * adjustedRatio.z;
}
