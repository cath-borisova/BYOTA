shader_type spatial;

uniform vec2 corner1 = vec2(0, 0);
uniform vec2 corner2 = vec2(0, 0);

 void vertex() {
	vec2 top_left = vec2(-0.128, -0.128);
	vec2 relative_displacement = VERTEX.xz - top_left;
	vec2 displacement = corner2 - corner1;
	vec2 corner1_corrected, corner2_corrected;
	if (displacement.x * displacement.y < 0.0) {
		corner1_corrected = vec2(corner1.x, corner2.y);
		corner2_corrected = vec2(corner2.x, corner1.y);
	} else {
		corner1_corrected = corner1;
		corner2_corrected = corner2;
	}
	displacement = corner2_corrected - corner1_corrected;
	VERTEX.xz =  corner1_corrected + mix(vec2(0, 0), displacement, relative_displacement / (vec2(0.256, 0.256)));
}

void fragment() {
    ALBEDO = vec3(0.009, 0.118, 0.263); 
	ALPHA = 0.7;
}