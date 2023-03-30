

// random float 0 <= r < 1
float randf(float seed)
{
    return frac(sin(dot(seed, 10.233)) * 12228.1903);
}

float rand_range(float seed, float min, float max)
{
    float r = randf(seed);
    r = lerp(min, max, r);
    return r;
}

float noise(float2 uv)
{
    return (randf(uv.x) + randf(uv.y)) / 2;
}

float noise_block(float2 uv, float seed, float2 scale)
{
    float2 s = 1.0 / scale;
    float2 suv = uv + s / 2.0;
    suv /= s;
    suv = round(suv);
    suv *= s;

    float n = randf(randf(suv.x) + seed) + randf(suv.y + seed);
    n /= 2.0;
    n = randf(n);
    
    return n;
    
}

float noise_perlin2(float2 uv, float seed, float2 scale)
{
    float2 cellSize = 1.0 / scale;
    float2 suv = uv * scale;
    //セル単位の座標
    float2 celluv = suv % 1;
    // 離散化
    suv = floor(suv);
    
    // smooth step
    float2 u = celluv * celluv * celluv * (6 * celluv * celluv - 15 * celluv + 10);
    //float2 u = celluv * celluv *(3 - 2 * celluv);
    //corner vertex position
    float2 v00 = suv + float2(0,0);
    float2 v01 = suv + float2(0,1);
    float2 v10 = suv + float2(1,0);
    float2 v11 = suv + float2(1,1);
    //gradient
    float2 g00 = float2(randf(v00.x + v00.y * seed + 0.3), randf(v00.y + v00.x * seed)) * 2.0 - 1.0;
    float2 g10 = float2(randf(v10.x + v10.y * seed + 0.3), randf(v10.y + v10.x * seed)) * 2.0 - 1.0;
    float2 g01 = float2(randf(v01.x + v01.y * seed + 0.3), randf(v01.y + v01.x * seed)) * 2.0 - 1.0;
    float2 g11 = float2(randf(v11.x + v11.y * seed + 0.3), randf(v11.y + v11.x * seed)) * 2.0 - 1.0;
    float r = lerp(lerp(dot(g00/length(g00), (celluv - float2(0,0))), dot(g10/length(g10), (celluv - float2(1,0))), u.x), lerp(dot(g01/length(g01), (celluv - float2(0,1))), dot(g11/length(g11), (celluv - float2(1,1))), u.x), u.y) + 0.5; 
    //r = r / 2 + 0.5;
    return r;
}

float4 noise_overlay(float4 baseColor, float2 uv, float seed, float2 scale)
{
    float4 noise = float4(1,1,1,1) * noise_perlin2(uv, seed, scale);
    
    // noise = baseColor + (noise - baseColor) * 0.2;
    float s = step(baseColor, 0.5);
    float4 b = baseColor * noise / 1 * 2;
    float4 t = 2 * (baseColor + noise - baseColor * noise / 1) - 1;
    float4 col = lerp(t, b, s);
    col = baseColor + (col - baseColor) * 0.2;
    return float4(col.x, col.y, col.z, baseColor.w);
}