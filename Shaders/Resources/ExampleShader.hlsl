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

void morphLandscape(out float4 pos)
{

}

// The vertex shader entry point. This function takes a single vertex and transforms it for the rasteriser.
void VSMain(const VSInput input, out PSInput output)
{
	//const float dt = 0.016f;
	output.pos = mul(input.pos, g_WVP);
	output.normal = input.normal;
	{
		//Uncomment to enable morphing landscape
		//output.pos.y *= tan(radians(g_frameCount));
		//morph landscape
	}
	output.colour = input.colour;
}

// The pixel shader entry point. This function writes out the fragment/pixel colour.
void PSMain(const PSInput input, out PSOutput output)
{
	const float lightIntensity = 0.5f;
	const float smallNum = 0.1f;

	//output.colour = input.colour;	// 'return' the colour value for this fragment.
	{
		//Uncomment for lighting
		float dp = 0.0f;
		for (int i = 0; i < g_numLights; ++i)
		{
			dp += dot(g_lightDirections[i], input.normal);
			// UNCOMMENT FOR CRAZY PATTERN
			//output.colour.x += sin(radians((dp * g_frameCount)));
			//output.colour.y += sin(radians((dp * g_frameCount)));
			//output.colour.z += cos(radians((dp * g_frameCount)));
			//output.colour = lightIntensity * input.colour * dp;
			

		}
		//comment out for crazy pattern
		output.colour = lightIntensity * input.colour * dp;
	}
	output.colour.w = 1.0f;


}