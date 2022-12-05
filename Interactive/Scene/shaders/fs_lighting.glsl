#version 410 core

out vec4 color;

in VS_OUT
{
    vec3 vertex;
    vec3 normals;
    vec2 tc;
} fs_in;

// uniform variables
uniform sampler2D tex;
uniform vec4 diffuseColour;
uniform vec4 specularColour;
uniform vec4 lightColour;
uniform vec3 lightPosition;
uniform vec3 cameraPosition;
uniform float diffuseConstant;
uniform float ambientConstant;
uniform float specularConstant;
uniform float shininessConstant;

void main()
{
	// surface normal
	vec3 normal = normalize(fs_in.normals);
	
	// diffusion
	vec3 lightDirection = normalize(lightPosition - fs_in.vertex);
	float diffuse = max(dot(normal, lightDirection), 0.0f);
	
	// specular reflections
	vec3 viewDirection = normalize(cameraPosition - fs_in.vertex);
	vec3 reflectionDirection = reflect(-lightDirection, normal);
	float specAmount = pow(max(dot(viewDirection, reflectionDirection), 0.0f), shininessConstant);
	float specular = specAmount * specularConstant;

	// update color values
	color = vec4(ambientConstant * lightColour.rgb + diffuseConstant * diffuseColour.rgb * (diffuse * diffuseColour).rgb + specularConstant * specularColour.rgb * specular, 1.0) * texture(tex, fs_in.tc);
}