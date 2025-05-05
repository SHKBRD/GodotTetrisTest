shader_type spatial;

instance uniform vec4 blockColor : source_color = vec4(0.4, 0.4, 0.4, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = blockColor.xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
