//
//  ToneMapSDR.ci.metal
//  ToneMapDemo
//
//  Created by Jeffrey Blagdon on 2025-02-26.
//

#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" float4 ToneMapSDR (coreimage::sample_t s, coreimage::destination dest)
{
    return float4(s.g, s.b, s.r, s.a);
}

