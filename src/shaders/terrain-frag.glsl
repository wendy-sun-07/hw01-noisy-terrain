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

void main()
{
    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    //out_Col = vec4(mix(vec3(0.5 * (fs_Sine + 1.0)), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);

    float height = fs_Height / 7.0;
    float moisure = fs_Moisture / 5.0;

    if (height <= 0.1) color = vec4(135.0 / 255.0, 206.0 / 255.0, 235.0 / 255.0, 1.0);
    else if (height < 0.12 && height > 0.1) color = vec4(173.0 / 255.0, 216.0 / 255.0, 230.0 / 255.0, 1.0);

  else if (height > 0.25) {
    if (moisure <= 0.2)  color = vec4(72.0 / 255.0, 61.0 / 255.0, 169.0 / 255.0, 1.0);
    else if (moisure <= 1.6 && moisure > 1.0) color = vec4(216.0 / 255.0, 191.0 / 255.0, 216.0 / 255.0, 1.0);
    else if (moisure > 1.6) color = vec4(221.0 / 255.0, 160.0 / 255.0, 221.0 / 255.0, 1.0);
  }

  // else if (height > 0.2 && height <= 0.25) {
  //   if (moisure <= 0.1) color = vec4(106.0 / 255.0, 95.0 / 255.0, 205.0 / 255.0, 0.2);
  //   if (moisure <= 0.2 && moisure > 0.1) color = vec4(72.0 / 255.0, 61.0 / 255.0, 139.0 / 255.0, 0.1);
  //   else color = vec4(123.0 / 255.0, 104.0 / 255.0, 238.0 / 255.0, 0.9);
  // }
  //
  // else if (height > 0.3) {
  //   if (moisure <= 0.16) color = vec4(138.0 / 255.0, 43.0 / 255.0, 226.0 / 255.0, 1.0);
  //   if (moisure <= 0.2 && moisure > 0.16) color = vec4(147.0 / 255.0, 112.0 / 255.0, 219.0 / 255.0, 1.0);
  //   if (moisure <= 0.3 && moisure > 0.2) color = vec4(65.0 / 255.0, 105.0 / 255.0, 225.0 / 255.0, 1.0);
  //   else color = vec4(75.0 / 255.0, 0.0 / 255.0, 108.0 / 255.0, 1.0);
  // }
  //
  // else if (moisure <= 0.16) color = vec4(72.0 / 255.0, 61.0 / 255.0, 139.0 / 255.0, 1.0);
  // else if (moisure <= 0.2 && moisure > 0.16) color = vec4(186.0 / 255.0, 85.0 / 255.0, 211.0 / 255.0, 1.0);
  // else if (moisure <= 0.3 && moisure > 0.2) color = vec4(65.0 / 255.0, 105.0 / 255.0, 220.0 / 255.0, 1.0);
  // else color = vec4(75.0 / 255.0, 0.0 / 255.0, 108.0 / 255.0, 0.4);

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
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
