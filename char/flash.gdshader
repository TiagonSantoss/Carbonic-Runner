shader_type canvas_item;

uniform float flash_strength = 0.0;  // 0 = normal, 1 = full flash
uniform float follower_gray = 0.0;   // 0 = normal, 1 = gray
uniform vec3 flash_color = vec3(1.0,1.0,1.0); // white flash

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Convert to grayscale only if follower_gray > 0
	vec3 gray_color = vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114)));

	vec3 final_color = mix(tex_color.rgb, gray_color, follower_gray);

	// Apply flash on top
	final_color = mix(final_color, flash_color, flash_strength);

	COLOR = vec4(final_color, tex_color.a);
}
