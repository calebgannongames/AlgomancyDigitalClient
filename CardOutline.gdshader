shader_type spatial;
render_mode unshaded;
uniform sampler2D noise;
void fragment(){;
float time = (TIME/6.0);
vec2 uv = mod(vec2(UV.x + time*0.5, 0.75*UV.y + 0.25*time), 1.0);
ALPHA = texture(noise, uv).a*texture(noise, uv).a;
ALBEDO.rgb = texture(noise, uv).rgb;
//ALPHA *= 1.25*cos(UV.y*4.0 - 2.0);
//ALPHA *= 0.5*(1.0+cos((PI*UV.x + PI/2.0)*2.0));
//ALBEDO.g *= 1.25*cos(UV.y*4.0 - 2.0);
//ALBEDO.g *= 0.5*(1.15+cos((PI*UV.x + PI/2.0)*2.0));

//if (UV.x > 0.9){
	//COLOR.a = 0.0;
//}
//COLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),COLOR.rgb.rgb * (1.0 / 12.92),lessThan(COLOR.rgb,vec3(0.04045)));
//COLOR.r = time;
//COLOR.a = texture(TEXTURE, UV).a;
//COLOR.r = UV.x*100.0;
}


//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
