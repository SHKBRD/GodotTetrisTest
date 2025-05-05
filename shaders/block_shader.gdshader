shader_type spatial;

//render_mode unshaded;

instance uniform vec4 blockColor : source_color = vec4(0.4, 0.4, 0.4, 1.0);
instance uniform bool placed;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = blockColor.xyz;
	if (placed) {
		ALBEDO /= 4.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
