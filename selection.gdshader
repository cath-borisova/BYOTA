shader_type spatial;

uniform vec2 corner1 = vec2(0, 0);
uniform vec2 corner2 = vec2(0, 0);

void vertex() {
    vec2 displacement = corner2 - corner1;
    VERTEX.xz += mix(vec2(0.0), displacement, VERTEX.xz);


}

void fragment() {
    ALBEDO = vec3(0.009, 0.118, 0.263); 
	ALPHA = 0.7;
}