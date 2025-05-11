shader_type spatial;

void vertex() {
	
}

void fragment() {
	ALBEDO.rgb = vec3(0.0);
	ALPHA = 0.7;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
