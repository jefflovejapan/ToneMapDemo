//
//  ToneMapSDR.ci.metal
//  ToneMapDemo
//
//  Created by Jeffrey Blagdon on 2025-02-26.
//

#include <CoreImage/CoreImage.h>
using namespace metal;

/*
 Implementation of algorithm in Table 4 of BT.2446-1 (Conversion Method A, SDR to HDR conversion), available here: https://www.itu.int/dms_pub/itu-r/opb/rep/R-REP-BT.2446-1-2021-PDF-E.pdf
 */

[[stitchable]] float4 ToneMapSDR (coreimage::sample_t s, coreimage::destination dest)
{
    // 2. Convert RGB to YCbCr (using BT.2020-like coefficients)
    float3 rgb = s.rgb;
    float r = s.r;
    float g = s.g;
    float b = s.b;
    
    float Kr = 0.2627;
    float Kg = 0.6780;
    float Kb = 0.0593;
    
    float Y = dot(rgb, float3(Kr, Kg, Kb)); // luma (Y′)
    // Compute chroma differences from method in table 4 of ITU-R BT.2020, available here: https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2020-0-201208-S!!PDF-E.pdf
    float Cb = (rgb.b - Y) / 1.8814f;  // chroma blue difference
    float Cr = (rgb.r - Y) / 1.4746f;  // chroma red difference
    
    // 3. Range adjustment: scale Y′ [0,1] to Y″ in [0,255]
    float Y_dbl = Y * 255.0f;

    // 4. Compute the exponent E based on Y_dbl (piecewise function)
    float a1 = 1.8712e-5;
    float b1 = -2.7334e-3;
    float c1 = 1.3141;
    float a2 = 2.8305e-6;
    float b2 = -7.4622e-4;
    float c2 = 1.2528;
    float E;
    
    if (Y_dbl <= 70.0f) {
        E = (a1 * pow(Y_dbl, 2.0f)) + (b1 * Y_dbl) + c1;
    } else {
        E =  (a2 * pow(Y_dbl, 2.0f)) + (b2 * Y_dbl) + c2;
    }

    // 5. Map the luma to HDR luma using a power function
    float Y_hdr = pow(Y_dbl, E);  // This gives Yₕₑᵣ′ in [0, 1000] range

    // 6. Chroma scaling factor (SC)
    float SC = (Y > 0.0f) ? 1.075f * (Y_hdr / Y) : 1.0f;
    float Cb_hdr = Cb * SC;
    float Cr_hdr = Cr * SC;
    
    float LMax = 1000.0f;

    // 7. Convert the new YCbCr back to RGB using the inverse function f⁻¹
    //    Note: clamp to [0,1000] then normalize by 1000 and apply inverse gamma (power 2.4)
    float R_abs = pow((clamp(Y_hdr + (1.4746f * Cr_hdr), 0.0f, LMax) / LMax), 2.4f);
    float G_abs = pow((clamp(Y_hdr - (0.16455f * Cb_hdr) - (0.57135f * Cr_hdr), 0.0f, LMax) / LMax), 2.4f);
    float B_abs = pow((clamp((Y_hdr + 1.8814f * Cb_hdr), 0.0f, LMax) / LMax), 2.4f);

    // 8. Return the output HDR color (alpha is passed through)
    float3 absRGB = LMax * float3(R_abs, G_abs, B_abs);
    return float4(absRGB, s.a);
}
