#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec4 fs_LightVec;

in float fs_Sine;

in float fs_Height;

in float fs_Moisture;

out vec4 out_Col; // This is the final output color that you will see on your
// screen for the pixel that is currently being processed.

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float interpNoise2D(float x, float y) {
  float intX = floor(x);
  float fractX = fract(x);
  float intY = floor(y);
  float fractY = fract(y);

  float v1 = random1(vec2(intX, intY), vec2(311.7, 127.1));
  float v2 = random1(vec2(intX + 1.0f, intY), vec2(311.7, 127.1));
  float v3 = random1(vec2(intX, intY + 1.0f), vec2(311.7, 127.1));
  float v4 = random1(vec2(intX + 1.0, intY + 1.0), vec2(311.7, 127.1));

  float i1 = mix(v1, v2, fractX);
  float i2 = mix(v3, v4, fractX);

  return mix(i1, i2, fractY);
}

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float freq ){
	float unit = 1.5/freq;
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	xy = .5*(1.-cos(3.14*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

float pNoise(vec2 p, int res){
	float persistance = .5;
	float n = 0.;
	float normK = 0.;
	float f = 4.;
	float amp = 1.;
	int iCount = 0;
	for (int i = 0; i<20; i++){
		n+=amp*noise(p, f);
		f*=2.;
		normK+=amp;
		amp*=persistance;
		if (iCount == res) break;
		iCount++;
	}
	float nf = n/normK;
	return nf*nf*nf*nf;
}


float generateColor(float x, float y) {
  // noise 3.1 - color, using perlin noise as an input to fbm
  float total = 0.0;
  float persistence = 0.5f;
  float octaves = 5.0;

  for (float i = 0.0; i < octaves; i = i + 1.0) {
    float freq = pow(2.0f, i);
    float amp = pow(persistence, i);
    total += (1.0 / freq) * pNoise(vec2(x * freq, y * freq), 1);
  }
  return total;
}

float generateColor2(float x, float y) {
  // noise 3.2 - add noise in color just using fbm
  float total = 0.0;
  float persistence = 0.5f;
  float octaves = 5.0;

  for (float i = 0.0; i < octaves; i = i + 1.0) {
    float freq = pow(2.0f, i);
    float amp = pow(persistence, i);
    total += (1.0 / freq) * interpNoise2D(x * freq, y * freq);
  }
  return total;
}


void main()
{
  float fog = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
  //out_Col = vec4(mix(vec3(0.5 * (fs_Sine + 1.0)), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);

  float height = fs_Height / 7.0;
  float moisture = fs_Moisture / 5.0;

  // all the colors!

  vec4 BEIGE_FLAT = vec4(245.0 / 255.0, 245.0 / 255.0, 220.0 / 255.0, 1.0);
  vec4 color = BEIGE_FLAT;
  vec4 DEEP_OCEAN = vec4(135.0 / 255.0, 206.0 / 255.0, 235.0 / 255.0, 1.0);
  vec4 OCEAN = mix(DEEP_OCEAN, vec4(173.0 / 255.0, 216.0 / 255.0, 230.0 / 255.0, 1.0),
                  height * 6.0);
  vec4 LIGHT_BEACH =mix(vec4(135.0 / 255.0, 206.0 / 255.0, 235.0 / 255.0, 1.0), BEIGE_FLAT, (height - 0.1) * 8.0);
  vec4 DESERT = mix(BEIGE_FLAT, vec4(255.0 / 255.0, 192.0 / 255.0, 203.0 / 255.0, 1.0),
  moisture * 3.5);
  vec4 TEMP_DESERT_BEACH = mix(LIGHT_BEACH, DESERT, moisture / 2.0);
  vec4 DESERT_BEACH = mix(TEMP_DESERT_BEACH, vec4(216.0 / 255.0, 192.0 / 255.0, 218.0 / 255.0, 1.0),
                      moisture / 2.0);
  vec4 TROPIC = mix(DESERT_BEACH, vec4(72.0 / 255.0, 209.0 / 255.0, 204.0 / 255.0, 1.0),
                    ((height - 0.29) * 6.0 - moisture * 0.5));
  vec4 BEIGE = mix(TROPIC, vec4(245.0 / 255.0, 245.0 / 255.0, 220.0 / 255.0, 1.0),
                   (moisture - 0.3) * 3.0);
  vec4 PEAK = mix(TROPIC, vec4(64.0 / 224.0, 209.0 / 255.0, 203.0 / 255.0, 1.0),
                  (height - 0.30) * 2.0);

  vec4 PINKY = mix(vec4(216.0 / 224.0, 192.0 / 255.0, 216.0 / 255.0, 1.0), PEAK,
                  (0.88 - 0.30) * 1.3);

  if (height <= 0.07) {
    color = DEEP_OCEAN;
  }
  if (height <= 0.10 && height > 0.07) {
    color = OCEAN;
  }

  if (height > 0.1 && height < 0.2) {
    color = LIGHT_BEACH;
  }

  if (height >= 0.2 && height < 0.3) {
    if (moisture <= 0.4) {
      color = DESERT * fract(generateColor(fs_Pos.x + u_PlanePos.x, fs_Pos.z + u_PlanePos.y));
    }
    else {
      color = BEIGE;
    }
  }

  if (height >= 0.3 && height < 0.55) {
    if (moisture <= 0.3) {
      color = TROPIC * fract(generateColor2((fs_Pos.x + u_PlanePos.x) / 8.0,
                                            (fs_Pos.z + u_PlanePos.y) / 8.0));
    }
    else {
      color = BEIGE;
    }
  }

  if (height > 0.55 && height < 0.8) {
      color = PEAK * fract(generateColor2((fs_Pos.x + u_PlanePos.x) / 8.0,
                                            (fs_Pos.z + u_PlanePos.y) / 8.0));
  }

  if (height >= 0.8) {
    color = PINKY * fract(generateColor2((fs_Pos.x + u_PlanePos.x) / 2.0,
                                    (fs_Pos.z + u_PlanePos.y) / 2.0));
  }


  // Material base color (before shading)
  vec4 diffuseColor = color;

  // Calculate the diffuse term for Lambert shading
  float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
  // Avoid negative lighting values
  // diffuseTerm = clamp(diffuseTerm, 0, 1);

  float ambientTerm = 0.2;

  float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
  //to simulate ambient lighting. This ensures that faces that are not
  //lit by our point light are not completely black.

  // Compute final shaded color
  out_Col = mix(diffuseColor, vec4(1.0), fog);
}
