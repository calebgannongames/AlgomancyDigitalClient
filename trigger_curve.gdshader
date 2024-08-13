shader_type canvas_item;

uniform sampler2D noise;
void fragment(){;
float time = (TIME);
vec2 uv = mod(vec2(UV.x + time*0.5, 0.75*UV.y + 0.25*time), 1.0);

COLOR = texture(noise, uv);
COLOR.a *= 1.25*cos(UV.y*4.0 - 2.0);
COLOR.a *= 0.5*(1.15+cos((PI*UV.x + PI/2.0)*2.0));

//if (UV.x > 0.9){
	//COLOR.a = 0.0;
//}
//COLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),COLOR.rgb.rgb * (1.0 / 12.92),lessThan(COLOR.rgb,vec3(0.04045)));
//COLOR.r = time;
//COLOR.a = texture(TEXTURE, UV).a;
//COLOR.r = UV.x*100.0;
}
