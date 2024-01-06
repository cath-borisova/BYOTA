shader_type spatial;
//uniform means it can be accessed in inspector (click on selectionbox -> mesh -> material -> shader parameters)
uniform vec2 corner1 = vec2(0, 0);
uniform vec2 corner2 = vec2(0.5, 0.5);

void vertex() {
	vec2 top_left = vec2(0.128, 0.128);
	vec2 relative_displacement = VERTEX.xz - top_left;
    vec2 displacement = corner2 - corner1;
	// float size = 0.256;
    //VERTEX.xz = mix(corner1, corner2, VERTEX.xz/size);
	VERTEX.xz = corner1 + mix(vec2(0, 0), -displacement, relative_displacement / (top_left * 2.0));
}

void fragment() {
	// dont worry about this code - its color and transparency
    ALBEDO = vec3(0.009, 0.118, 0.263); 
	ALPHA = 0.7;
}