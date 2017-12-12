//////////////////////////////////////////////////////////////////////
// HLSL File:
// This example is compiled using the fxc shader compiler.
// It is possible directly compile HLSL in VS2013
//////////////////////////////////////////////////////////////////////

// This first constant buffer is special.
// The framework looks for particular variables and sets them automatically.
// See the CommonApp comments for the names it looks for.
cbuffer CommonApp
{
	float4x4 g_WVP;
	float4 g_lightDirections[MAX_NUM_LIGHTS];
	float3 g_lightColours[MAX_NUM_LIGHTS];
	int g_numLights;
	float4x4 g_InvXposeW;
	float4x4 g_W;
};


// When you define your own cbuffer you can use a matching structure in your app but you must be careful to match data alignment.
// Alternatively, you may use shader reflection to find offsets into buffers based on variable names.
// The compiler may optimise away the entire cbuffer if it is not used but it shouldn't remove indivdual variables within it.
// Any 'global' variables that are outside an explicit cbuffer go
// into a special cbuffer called "$Globals". This is more difficult to work with
// because you must use reflection to find them.
// Also, the compiler may optimise individual globals away if they are not used.
cbuffer MyApp
{
	float	g_frameCount;
	float3	g_waveOrigin;
}


// VSInput structure defines the vertex format expected by the input assembler when this shader is bound.
// You can find a matching structure in the C++ code.
struct VSInput
{
	float4 pos:POSITION;
	float4 colour:COLOUR0;
	float3 normal:NORMAL;
	float2 tex:TEXCOORD;
};

// PSInput structure is defining the output of the vertex shader and the input of the pixel shader.
// The variables are interpolated smoothly across triangles by the rasteriser.
struct PSInput
{
	float4 pos:SV_Position;
	float4 colour:COLOUR0;
	float3 normal:NORMAL;
	float2 tex:TEXCOORD;
	float4 mat:COLOUR1;
};

// PSOutput structure is defining the output of the pixel shader, just a colour value.
struct PSOutput
{
	float4 colour:SV_Target;
};

// Define several Texture 'slots'
Texture2D g_materialMap;
Texture2D g_texture0;
Texture2D g_texture1;
Texture2D g_texture2;


// Define a state setting 'slot' for the sampler e.g. wrap/clamp modes, filtering etc.
SamplerState g_sampler;

// The vertex shader entry point. This function takes a single vertex and transforms it for the rasteriser.
void VSMain(const VSInput input, out PSInput output)
{
	//const float dt = 0.016f;
	const float size = 512;
	float2 pixelPos = float2((input.pos.x + size) / (size * 2), (input.pos.z + size) / (size * 2));
	pixelPos.y = 1.0 - pixelPos.y;

	float4 sampled = g_materialMap.SampleLevel(g_sampler, pixelPos, 0);
	output.pos = mul(input.pos, g_WVP);
	output.normal = input.normal;
	output.tex = input.tex;
	output.colour = sampled;

	{
		//Uncomment to enable morphing landscape
		//output.pos.y *= tan(radians(g_frameCount));
		//morph landscape
	}
}

// The pixel shader entry point. This function writes out the fragment/pixel colour.
void PSMain(const PSInput input, out PSOutput output)
{
	const float lightIntensity = 0.05f;
	const float smallNum = 0.1f;

	const float size = 512;
	float2 pixelPos = float2((input.pos.x + size) / (size * 2), (input.pos.z * size) / (size * 2));

	const float4 mossCol = g_texture0.Sample(g_sampler, input.tex);
	const float4 grassCol = g_texture1.Sample(g_sampler, input.tex);
	const float4 asphaltCol = g_texture2.Sample(g_sampler, input.tex);


	//
	output.colour = float4(0.0f, 0.0f, 0.0f, 1.0f);
	output.colour.r = lerp(output.colour.r, mossCol.r, input.colour.r) + lerp(output.colour.r, grassCol.r, input.colour.g) + lerp(output.colour.r, asphaltCol.r, input.colour.b);
	output.colour.g = lerp(output.colour.g, mossCol.g, input.colour.r) + lerp(output.colour.g, grassCol.g, input.colour.g) + lerp(output.colour.g, asphaltCol.g, input.colour.b);
	output.colour.b = lerp(output.colour.b, mossCol.b, input.colour.r) + lerp(output.colour.b, grassCol.b, input.colour.g) + lerp(output.colour.b, asphaltCol.b, input.colour.b);


	//output.colour = 
	//output.colour = input.colour;	// 'return' the colour value for this fragment.

	{
		//Uncomment for lighting
		float3 summedIntensity = float3(0.0f, 0.0f, 0.0f);
		for (int i = 0; i < g_numLights; ++i)
		{
			float dp = dot(normalize(g_lightDirections[i]), normalize(input.normal));
			dp = max(0, dp);
			summedIntensity += (dp * g_lightColours[i]);
			// UNCOMMENT FOR CRAZY PATTERN
			//output.colour.x += sin(radians((dp * g_frameCount)));
			//output.colour.y += sin(radians((dp * g_frameCount)));
			//output.colour.z += cos(radians((dp * g_frameCount)));
			//output.colour = lightIntensity * input.colour * dp;


		}
		output.colour.rgb *= summedIntensity;
		//comment out for crazy pattern
		//output.colour += summedIntensity;
		output.colour.w = 1.0f;
	}


}