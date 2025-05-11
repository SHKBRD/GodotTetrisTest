shader_type spatial;

render_mode unshaded;

uniform sampler2D albedo : filter_nearest_mipmap_anisotropic;
instance uniform int blockColorId;
instance uniform bool placed;
instance uniform float lockProgress;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 modUV = mod(UV/vec2(1.3333333,2.0), 0.25);
	float xColorOff = mod(float(blockColorId), 4.0)/4.0;
	float yColorOff = floor(float(blockColorId)/4.0)/4.0;
	ALBEDO.xyz = texture(albedo, modUV + vec2(xColorOff, yColorOff)).xyz;
	//ALBEDO *= blockColor.xyz;
	if (placed) {
		ALBEDO /= 2.0;
	} else {
		ALBEDO /= (1.0 + lockProgress);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
