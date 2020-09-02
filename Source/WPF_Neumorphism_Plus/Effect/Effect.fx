/**
* @file Effect.fx
* @brief Make Shadow Effect of Neumorphism UI.
* @author ryokohbato
*/

sampler2D Input             : register(S0);

float   OffsetX             : register(C0);
float   OffsetY             : register(C1);
float   BlurRadius          : register(C2);
float   SpreadRadius        : register(C3);
float   BorderRadius        : register(C4);
float4  PrimaryColor        : register(C5);
float4  SecondaryColor      : register(C6);
float   Inset               : register(C7);
float   RenderingMode       : register(C8);

float4  DdxDdy              : register(C9);

/**
* @brief Define rendering mode
* @param x (Expected: 0 <= x <= 1) Indicates the degree how far a point in the shadow is.
* @return float (Expected: 0 <= x <= 1) Indicates the degree how strongly the shadow will be weakend.
*/
float profileFunc(float x)
{
    if (1 < x)
        return 1;

    if (x < 0)
        return 0;

    if (RenderingMode == 1)
        return x;
    else if (RenderingMode == 2)
        return sin(x * 3.1415926 / 2);
    else
        return sin(x * 3.1415926 / 2);
}

/**
* @brief calculate the transparency of the shadow which is out of border.
* @param uv The shadow range which includes padding.
* @param OffsetDirection (Expected: 1 or -1) if this is 1, the offset is the same direction to that of box-shadow (CSS), and if this is -1, they are the opposite direction.
* @return float The transparency of the shadow.
*/
float outerShadowCalculator(float2 uv :TEXCOORD, float OffsetDirection) : COLOR
{
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

    float LeftEdge = abs(OffsetX) * length(DdxDdy.xy) + (BlurRadius + SpreadRadius) * length(DdxDdy.xy);
    float TopEdge = abs(OffsetY) * length(DdxDdy.zw) + (BlurRadius + SpreadRadius) * length(DdxDdy.zw);

    float ShadowBorderX = min(max(BlurEffectiveLengthX, (BlurRadius + SpreadRadius + BorderRadius) * length(DdxDdy.xy)), 0.5 - OffsetX * OffsetDirection * length(DdxDdy.xy));
    float ShadowBorderY = min(max(BlurEffectiveLengthY, (BlurRadius + SpreadRadius + BorderRadius) * length(DdxDdy.zw)), 0.5 - OffsetY * OffsetDirection * length(DdxDdy.zw));

    float ElmBorderRadiusX = BorderRadius * length(DdxDdy.xy);
    float ElmBorderRadiusY = BorderRadius * length(DdxDdy.zw);

    if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingRight && UnusedPaddingTop < uv.y && uv.y < UnusedPaddingBottom)
        &&
        (uv.x < LeftEdge || 1 - LeftEdge < uv.x || uv.y < TopEdge || 1 - TopEdge < uv.y
            || (pow((LeftEdge + ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((TopEdge + ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < LeftEdge + ElmBorderRadiusX && uv.y < TopEdge + ElmBorderRadiusY)
            || (pow((1 - LeftEdge - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((TopEdge + ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - LeftEdge - ElmBorderRadiusX < uv.x && uv.y < TopEdge + ElmBorderRadiusY)
            || (pow((LeftEdge + ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - TopEdge - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < LeftEdge + ElmBorderRadiusX && 1 - TopEdge - ElmBorderRadiusY < uv.y)
            || (pow((1 - LeftEdge - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - TopEdge - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - LeftEdge - ElmBorderRadiusX < uv.x && 1 - TopEdge - ElmBorderRadiusY < uv.y)
        ))
    {
        if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderX)
            &&
            (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderY))
                return profileFunc(1 - sqrt(pow(1 - (uv.x - UnusedPaddingLeft) / ShadowBorderX, 2) + pow(1 - (uv.y - UnusedPaddingTop) / ShadowBorderY, 2)));

        if ((UnusedPaddingLeft + ShadowBorderX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderX)
            &&
            (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderY))
                return profileFunc((uv.y - UnusedPaddingTop) / ShadowBorderY);

        if ((UnusedPaddingRight - ShadowBorderX < uv.x && uv.x < UnusedPaddingRight)
            &&
            (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderY))
                return profileFunc(1 - (sqrt(pow(1 - (UnusedPaddingRight - uv.x) / ShadowBorderX, 2) + pow(1 - (uv.y - UnusedPaddingTop) / ShadowBorderY, 2))));

        if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderX)
            &&
            (UnusedPaddingTop + ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderY))
            return profileFunc((uv.x - UnusedPaddingLeft) / ShadowBorderX);

        if ((UnusedPaddingLeft + ShadowBorderX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderX)
            &&
            (UnusedPaddingTop + ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderY))
            return 1;

        if ((UnusedPaddingRight - ShadowBorderX < uv.x && uv.x < UnusedPaddingRight)
            &&
            (UnusedPaddingTop + ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderY))
            return profileFunc((UnusedPaddingRight - uv.x) / ShadowBorderX);

        if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderX)
            &&
            (UnusedPaddingBottom - ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom))
            return profileFunc(1 - (sqrt(pow(1 - (uv.x - UnusedPaddingLeft) / ShadowBorderX, 2) + pow(1 - (UnusedPaddingBottom - uv.y) / ShadowBorderY, 2))));

        if ((UnusedPaddingLeft + ShadowBorderX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderX)
            &&
            (UnusedPaddingBottom - ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom))
            return profileFunc((UnusedPaddingBottom - uv.y) / ShadowBorderY);

        if ((UnusedPaddingRight - ShadowBorderX < uv.x && uv.x < UnusedPaddingRight)
            &&
            (UnusedPaddingBottom - ShadowBorderY < uv.y && uv.y < UnusedPaddingBottom))
            return profileFunc(1 - (sqrt(pow(1 - (UnusedPaddingRight - uv.x) / ShadowBorderX, 2) + pow(1 - (UnusedPaddingBottom - uv.y) / ShadowBorderY, 2))));
    }

    return 0;
}

float4 main(float2 uv : TEXCOORD) : COLOR
{
    float4 color = tex2D(Input, uv);

    float addRatio_1 = outerShadowCalculator(uv, 1);
    float addRatio_2 = outerShadowCalculator(uv, -1);

    float4 base = lerp(color, SecondaryColor, addRatio_2);
    return lerp(base, PrimaryColor, addRatio_1);
}
