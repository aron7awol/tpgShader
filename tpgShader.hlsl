// $MinimumShaderProfile: ps_3_0
// Test pattern generator

const static float3 xyY1 = {0.6568, 0.3395, 19.9354 / 10000};
const static float3 xyY2 = {0.6708, 0.3278, 19.9354 / 10000};
const static float3 xyY3 = {0.3029, 0.6732, 65.7366 / 10000};
const static float3 xyY4 = {0.2763, 0.6972, 65.7366 / 10000};
const static float3 xyY5 = {0.1474, 0.0562, 5.8715 / 10000};
const static float3 xyY6 = {0.1463, 0.0525, 5.8715 / 10000};

//const static float3 lin1 = {0.00791, 0.00087, 0};
//const static float3 lin2 = {0.00629, 0.00050, 0};

//const static float3 rgb1 = {0.1, 0, 0};
//const static float3 rgb2 = {0, 0.1, 0};

//PQ constants
const static float m1 = 2610.0 / 16384;
const static float m2 = 2523.0 / 32;
const static float m1inv = 16384 / 2610.0;
const static float m2inv = 32 / 2523.0;
const static float c1 = 3424 / 4096.0;
const static float c2 = 2413 / 128.0;
const static float c3 = 2392 / 128.0;

//Convert from linear 2020 RGB to XYZ
const static float3x3 RGB_2020_2_XYZ = {
      0.6369580,  0.1446169,  0.1688810,
      0.2627002,  0.6779981,  0.0593017,
      0.0000000,  0.0280727,  1.0609851
};

//Convert from XYZ to linear P3 RGB
const static float3x3 XYZ_2_P3_RGB = {
     2.4934969, -0.9313836, -0.4027108,
    -0.8294890,  1.7626641,  0.0236247,
     0.0358458, -0.0761724,  0.9568845
};

//Convert from XYZ to linear 2020 RGB
const static float3x3 XYZ_2_2020_RGB = {
     1.7166512, -0.3556708, -0.2533663,
    -0.6666844,  1.6164812,  0.0157685,
     0.0176399, -0.0427706,  0.9421031
};

//Convert from linear P3 RGB to XYZ
const static float3x3 P3_RGB_2_XYZ = {
     0.4865709,  0.2656677,  0.1982173,
     0.2289746,  0.6917385,  0.0792869,
     0.0000000,  0.0451134,  1.0439444
};

sampler s0 : register(s0);

// Convert PQ to linear RGB
float3 pq_to_lin(float3 pq) { 
  float3 p = pow(pq, m2inv);
  float3 d = max(p - c1, 0) / (c2 - c3 * p);
  return pow(d, m1inv);
}

// Convert linear RGB to PQ
float3 lin_to_pq(float3 lin) {
  float3 y = lin; 
  float3 p = (c1 + c2 * pow(y, m1)) / (1 + c3 * pow(y, m1));
  return pow(p, m2);
}

// Convert linear 2020 RGB to XYZ
float3 rgb_2020_to_xyz(float3 rgb) {
    return mul(RGB_2020_2_XYZ, rgb);
}

// Convert XYZ to linear P3 RGB
float3 xyz_to_P3_rgb(float3 xyz) {
    return mul(XYZ_2_P3_RGB, xyz);
}

// Convert XYZ to linear 2020 RGB
float3 xyz_to_2020_rgb(float3 xyz) {
    return mul(XYZ_2_2020_RGB, xyz);
}

// Convert linear P3 RGB to XYZ
float3 P3_rgb_to_xyz(float3 rgb) {
    return mul(P3_RGB_2_XYZ, rgb);
}
 
// Convert XYZ to xyY
float3 xyz_to_xyY(float3 xyz) {
    float Y = xyz.y;
    float x = xyz.x / (xyz.x + xyz.y + xyz.z);
    float y = xyz.y / (xyz.x + xyz.y + xyz.z);
    return float3(x, y, Y);
}

// Convert xyY to XYZ
float3 xyY_to_xyz(float3 xyY) {
    float Y = xyY.z;
    float X = xyY.x * Y / xyY.y;
    float Z = (1 - xyY.x - xyY.y) * Y / xyY.y;
    return float3(X, Y, Z);
}

float4 main(float2 tex : TEXCOORD0) : COLOR {
	float3 xyz1 = xyY_to_xyz(xyY1);
	float3 xyz2 = xyY_to_xyz(xyY2);
	float3 xyz3 = xyY_to_xyz(xyY3);
	float3 xyz4 = xyY_to_xyz(xyY4);
	float3 xyz5 = xyY_to_xyz(xyY5);
	float3 xyz6 = xyY_to_xyz(xyY6);

	float3 lin1 = saturate(xyz_to_2020_rgb(xyz1));
	float3 lin2 = saturate(xyz_to_2020_rgb(xyz2));
	float3 lin3 = saturate(xyz_to_2020_rgb(xyz3));
	float3 lin4 = saturate(xyz_to_2020_rgb(xyz4));
	float3 lin5 = saturate(xyz_to_2020_rgb(xyz5));
	float3 lin6 = saturate(xyz_to_2020_rgb(xyz6));

	float3 rgb1 = lin_to_pq(lin1);
	float3 rgb2 = lin_to_pq(lin2);
	float3 rgb3 = lin_to_pq(lin3);
	float3 rgb4 = lin_to_pq(lin4);
	float3 rgb5 = lin_to_pq(lin5);
	float3 rgb6 = lin_to_pq(lin6);

	if ((tex.x < 0.5) && (tex.y < 0.33333)) return float4(rgb1.r, rgb1.g, rgb1.b, 1);
	if ((tex.x < 0.5) && (tex.y >= 0.66667)) return float4(rgb5.r, rgb5.g, rgb5.b, 1);
	if (tex.x < 0.5) return float4(rgb3.r, rgb3.g, rgb3.b, 1);
	if ((tex.x >= 0.5) && (tex.y < 0.33333)) return float4(rgb2.r, rgb2.g, rgb2.b, 1);
	if ((tex.x >= 0.5) && (tex.y >= 0.66667)) return float4(rgb6.r, rgb6.g, rgb6.b, 1);
	return float4(rgb4.r, rgb4.g, rgb4.b, 1);

	//if (tex.x < 0.5) return float4(rgb1.r, rgb1.g, rgb1.b, 1);
	//return float4(rgb2.r, rgb2.g, rgb2.b, 1);
}
