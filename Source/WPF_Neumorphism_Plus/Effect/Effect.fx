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

    float ShadowBorderRadiusX = min(max(BlurEffectiveLengthX, (BlurRadius + SpreadRadius + BorderRadius) * length(DdxDdy.xy)), 0.5 - OffsetX * OffsetDirection * length(DdxDdy.xy));
    float ShadowBorderRadiusY = min(max(BlurEffectiveLengthY, (BlurRadius + SpreadRadius + BorderRadius) * length(DdxDdy.zw)), 0.5 - OffsetY * OffsetDirection * length(DdxDdy.zw));

    float ElmBorderRadiusX = BorderRadius * length(DdxDdy.xy);
    float ElmBorderRadiusY = BorderRadius * length(DdxDdy.zw);

    if (!((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingRight && UnusedPaddingTop < uv.y && uv.y < UnusedPaddingBottom)
        &&
        (uv.x < LeftEdge || 1 - LeftEdge < uv.x || uv.y < TopEdge || 1 - TopEdge < uv.y
            || (pow((LeftEdge + ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((TopEdge + ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < LeftEdge + ElmBorderRadiusX && uv.y < TopEdge + ElmBorderRadiusY)
            || (pow((1 - LeftEdge - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((TopEdge + ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - LeftEdge - ElmBorderRadiusX < uv.x && uv.y < TopEdge + ElmBorderRadiusY)
            || (pow((LeftEdge + ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - TopEdge - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < LeftEdge + ElmBorderRadiusX && 1 - TopEdge - ElmBorderRadiusY < uv.y)
            || (pow((1 - LeftEdge - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - TopEdge - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - LeftEdge - ElmBorderRadiusX < uv.x && 1 - TopEdge - ElmBorderRadiusY < uv.y)
        )))
        return 0;

    if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderRadiusX)
        &&
        (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderRadiusY))
        return profileFunc(1 - sqrt(pow(1 - (uv.x - UnusedPaddingLeft) / ShadowBorderRadiusX, 2) + pow(1 - (uv.y - UnusedPaddingTop) / ShadowBorderRadiusY, 2)));

    if ((UnusedPaddingLeft + ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderRadiusX)
        &&
        (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderRadiusY))
        return profileFunc((uv.y - UnusedPaddingTop) / ShadowBorderRadiusY);

    if ((UnusedPaddingRight - ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight)
        &&
        (UnusedPaddingTop < uv.y && uv.y < UnusedPaddingTop + ShadowBorderRadiusY))
        return profileFunc(1 - (sqrt(pow(1 - (UnusedPaddingRight - uv.x) / ShadowBorderRadiusX, 2) + pow(1 - (uv.y - UnusedPaddingTop) / ShadowBorderRadiusY, 2))));

    if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderRadiusX)
        &&
        (UnusedPaddingTop + ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderRadiusY))
        return profileFunc((uv.x - UnusedPaddingLeft) / ShadowBorderRadiusX);

    if ((UnusedPaddingLeft + ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderRadiusX)
        &&
        (UnusedPaddingTop + ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderRadiusY))
        return 1;

    if ((UnusedPaddingRight - ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight)
        &&
        (UnusedPaddingTop + ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom - ShadowBorderRadiusY))
        return profileFunc((UnusedPaddingRight - uv.x) / ShadowBorderRadiusX);

    if ((UnusedPaddingLeft < uv.x && uv.x < UnusedPaddingLeft + ShadowBorderRadiusX)
        &&
        (UnusedPaddingBottom - ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom))
        return profileFunc(1 - (sqrt(pow(1 - (uv.x - UnusedPaddingLeft) / ShadowBorderRadiusX, 2) + pow(1 - (UnusedPaddingBottom - uv.y) / ShadowBorderRadiusY, 2))));

    if ((UnusedPaddingLeft + ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight - ShadowBorderRadiusX)
        &&
        (UnusedPaddingBottom - ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom))
        return profileFunc((UnusedPaddingBottom - uv.y) / ShadowBorderRadiusY);

    if ((UnusedPaddingRight - ShadowBorderRadiusX < uv.x && uv.x < UnusedPaddingRight)
        &&
        (UnusedPaddingBottom - ShadowBorderRadiusY < uv.y && uv.y < UnusedPaddingBottom))
        return profileFunc(1 - (sqrt(pow(1 - (UnusedPaddingRight - uv.x) / ShadowBorderRadiusX, 2) + pow(1 - (UnusedPaddingBottom - uv.y) / ShadowBorderRadiusY, 2))));

    return 0;
}

float minmax(float number, float min, float max)
{
    if (number < min)
        return min;

    if (max < number)
        return max;

    return number;
}

/**
* @brief Calculate the transparency of the shadow which is within the border.
* @param uv The shadow range.
* @param OffsetDirection (Expected: 1 or -1) if this is 1, the offset is the same direction to that of box-shadow (CSS), and if this is -1, they are the opposite direction.
* @return float The transparency of the shadow.
*/
float innerShadowCalculator(float2 uv :TEXCOORD, float OffsetDirection) :COLOR
{
    float BlurEffectiveLengthX = 2 * BlurRadius * length(DdxDdy.xy);
    float BlurEffectiveLengthY = 2 * BlurRadius * length(DdxDdy.zw);

    float LeftEdgeOfLeft = minmax((OffsetX * OffsetDirection + SpreadRadius - BlurRadius) * length(DdxDdy.xy), 0, 1);
    float RightEdgeOfRight = minmax(1 - (-OffsetX * OffsetDirection + SpreadRadius - BlurRadius) * length(DdxDdy.xy), 0, 1);
    float TopEdgeOfTop = minmax((OffsetY * OffsetDirection + SpreadRadius - BlurRadius) * length(DdxDdy.zw), 0, 1);
    float BottomEdgeOfBottom = minmax(1 - (-OffsetY * OffsetDirection + SpreadRadius - BlurRadius) * length(DdxDdy.zw), 0, 1);

    float RightEdgeOfLeft = min((OffsetX * OffsetDirection + SpreadRadius + BlurRadius) * length(DdxDdy.xy), 0.5 + OffsetX * OffsetDirection * length(DdxDdy.xy));
    float LeftEdgeOfRight = max(1 - (-OffsetX * OffsetDirection + SpreadRadius + BlurRadius) * length(DdxDdy.xy), 0.5 + OffsetX * OffsetDirection * length(DdxDdy.xy));
    float BottomEdgeOfTop = min((OffsetY * OffsetDirection + SpreadRadius + BlurRadius) * length(DdxDdy.zw), 0.5 + OffsetY * OffsetDirection * length(DdxDdy.zw));
    float TopEdgeOfBottom = max(1 - (-OffsetY * OffsetDirection + SpreadRadius + BlurRadius) * length(DdxDdy.zw), 0.5 + OffsetY * OffsetDirection * length(DdxDdy.zw));

    float ElmBorderRadiusX = BorderRadius * length(DdxDdy.xy);
    float ElmBorderRadiusY = BorderRadius * length(DdxDdy.zw);

    float ShadowBorderRadiusX = max(BorderRadius, BlurRadius + SpreadRadius) * length(DdxDdy.xy);
    float ShadowBorderRadiusY = max(BorderRadius, BlurRadius + SpreadRadius) * length(DdxDdy.zw);

    if ((pow((ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < ElmBorderRadiusX && uv.y < ElmBorderRadiusY)
        || (pow((1 - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - ElmBorderRadiusX < uv.x && uv.y < ElmBorderRadiusY)
        || (pow((ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && uv.x < ElmBorderRadiusX && 1 - ElmBorderRadiusY < uv.y)
        || (pow((1 - ElmBorderRadiusX - uv.x) / ElmBorderRadiusX, 2) + pow((1 - ElmBorderRadiusY - uv.y) / ElmBorderRadiusY, 2) > 1 && 1 - ElmBorderRadiusX < uv.x && 1 - ElmBorderRadiusY < uv.y)
        )
        return 0;

    if (uv.x < LeftEdgeOfLeft || RightEdgeOfRight < uv.x || uv.y < TopEdgeOfTop || BottomEdgeOfBottom < uv.y)
        return 1;

    if (BorderRadius < BlurRadius + SpreadRadius)
    {
        if (uv.x < ShadowBorderRadiusX + OffsetX * OffsetDirection * length(DdxDdy.xy) && uv.y < ShadowBorderRadiusY + OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc(sqrt(pow((RightEdgeOfLeft - uv.x) / BlurEffectiveLengthX, 2) + pow((BottomEdgeOfTop - uv.y) / BlurEffectiveLengthY, 2)));

        if (1 - uv.x < ShadowBorderRadiusX - OffsetX * OffsetDirection * length(DdxDdy.xy) && uv.y < ShadowBorderRadiusY + OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc(sqrt(pow((uv.x - LeftEdgeOfRight) / BlurEffectiveLengthX, 2) + pow((BottomEdgeOfTop - uv.y) / BlurEffectiveLengthY, 2)));

        if (uv.x < ShadowBorderRadiusX + OffsetX * OffsetDirection * length(DdxDdy.xy) && 1 - uv.y < ShadowBorderRadiusY - OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc(sqrt(pow((RightEdgeOfLeft - uv.x) / BlurEffectiveLengthX, 2) + pow((uv.y - TopEdgeOfBottom) / BlurEffectiveLengthY, 2)));

        if (1 - uv.x < ShadowBorderRadiusX - OffsetX * OffsetDirection * length(DdxDdy.xy) && 1 - uv.y < ShadowBorderRadiusY - OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc(sqrt(pow((uv.x - LeftEdgeOfRight) / BlurEffectiveLengthX, 2) + pow((uv.y - TopEdgeOfBottom) / BlurEffectiveLengthY, 2)));
    }
    else
    {
        if (uv.x < ShadowBorderRadiusX + OffsetX * OffsetDirection * length(DdxDdy.xy) && uv.y < ShadowBorderRadiusY + OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc((sqrt(pow(BorderRadius + OffsetX * OffsetDirection - uv.x / length(DdxDdy.xy), 2) + pow(BorderRadius + OffsetY * OffsetDirection - uv.y / length(DdxDdy.zw), 2)) - (BorderRadius - SpreadRadius - BlurRadius)) / (2 * BlurRadius));

        if (1 - uv.x < ShadowBorderRadiusX - OffsetX * OffsetDirection * length(DdxDdy.xy) && uv.y < ShadowBorderRadiusY + OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc((sqrt(pow(BorderRadius - OffsetX * OffsetDirection - (1 - uv.x) / length(DdxDdy.xy), 2) + pow(BorderRadius + OffsetY * OffsetDirection - uv.y / length(DdxDdy.zw), 2)) - (BorderRadius - SpreadRadius - BlurRadius)) / (2 * BlurRadius));

        if (uv.x < ShadowBorderRadiusX + OffsetX * OffsetDirection * length(DdxDdy.xy) && 1 - uv.y < ShadowBorderRadiusY - OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc((sqrt(pow(BorderRadius + OffsetX * OffsetDirection - uv.x / length(DdxDdy.xy), 2) + pow(BorderRadius - OffsetY * OffsetDirection - (1 - uv.y) / length(DdxDdy.zw), 2)) - (BorderRadius - SpreadRadius - BlurRadius)) / (2 * BlurRadius));

        if (1 - uv.x < ShadowBorderRadiusX - OffsetX * OffsetDirection * length(DdxDdy.xy) && 1 - uv.y < ShadowBorderRadiusY - OffsetY * OffsetDirection * length(DdxDdy.zw))
            return profileFunc((sqrt(pow(BorderRadius - OffsetX * OffsetDirection - (1 - uv.x) / length(DdxDdy.xy), 2) + pow(BorderRadius - OffsetY * OffsetDirection - (1 - uv.y) / length(DdxDdy.zw), 2)) - (BorderRadius - SpreadRadius - BlurRadius)) / (2 * BlurRadius));
    }

    if (uv.x < RightEdgeOfLeft)
        return profileFunc((RightEdgeOfLeft - uv.x) / BlurEffectiveLengthX);

    if (LeftEdgeOfRight < uv.x)
        return profileFunc((uv.x - LeftEdgeOfRight) / BlurEffectiveLengthX);

    if (uv.y < BottomEdgeOfTop)
        return profileFunc((BottomEdgeOfTop - uv.y) / BlurEffectiveLengthY);

    if (TopEdgeOfBottom < uv.y)
        return profileFunc((uv.y - TopEdgeOfBottom) / BlurEffectiveLengthY);

    return 0;
}

float4 main(float2 uv : TEXCOORD) : COLOR
{
    float4 color = tex2D(Input, uv);
    float addRatio_1;
    float addRatio_2;

    if (Inset == 0)
    {
      addRatio_1 = outerShadowCalculator(uv, 1);
      addRatio_2 = outerShadowCalculator(uv, -1);
  
    }
    else
    {
      addRatio_1 = innerShadowCalculator(uv, 1);
      addRatio_2 = innerShadowCalculator(uv, -1);
    }

      float4 base = lerp(color, SecondaryColor, addRatio_2);
      return lerp(base, PrimaryColor, addRatio_1);
}
