shader_type spatial;

uniform vec2 corner1 = vec2(0, 0);
uniform vec2 corner2 = vec2(0, 0);

void vertex() {
	vec2 top_left = vec2(-0.128, -0.128);
	vec2 relative_displacement = VERTEX.xz - top_left;
	vec2 displacement = corner2 - corner1;
	VERTEX.xz =  corner1 + mix(vec2(0, 0), displacement, relative_displacement / (vec2(0.256, 0.256)));
}

void fragment() {
    ALBEDO = vec3(0.009, 0.118, 0.263); 
	ALPHA = 0.7;
}