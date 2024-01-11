shader_type spatial;

uniform float my_lambert_factor : hint_range(0.0, 1.0) = 1.0;

void vertex() {
    // Transform vertex positions to world space
    VERTEX = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

//void light() {
    //// Compute Lambertian lighting
    //
//
    //// Output the final color with custom parameter
//}


void fragment() {
	 //ALBEDO = vec3(0.009, 0.118, 0.263); 
	vec3 light_direction = normalize(vec3(0.0, 1.0, 0.0));  // Directional light pointing downward
    float lambert = max(dot(normalize(NORMAL), -light_direction), 0.0);
	ALBEDO = my_lambert_factor * lambert;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
