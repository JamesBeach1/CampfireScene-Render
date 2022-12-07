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
uniform vec3 flashlightPosition;
uniform vec4 flashlightColour;
uniform vec3 flashlightDirection;
uniform vec3 cameraPosition;
uniform float diffuseConstant;
uniform float ambientConstant;
uniform float specularConstant;
uniform float shininessConstant;
uniform int isFlashlightOn;

vec4 dirLight()
{
	// surface normal
	vec3 normal = normalize(fs_in.normals);

	// diffusion
	vec3 lightDirection = normalize(lightPosition - fs_in.vertex);
	float diffuse = max(dot(normal, lightDirection), 0.0f);

	// specular lighting
	vec3 viewDirection = normalize(cameraPosition - fs_in.vertex);
	vec3 reflectionDirection = reflect(-lightDirection, normal);
	float specAmount = pow(max(dot(viewDirection, reflectionDirection), 0.0f), shininessConstant);
	float specular = specAmount * specularConstant;

	vec4 output = vec4(ambientConstant * lightColour.rgb + diffuseConstant * diffuseColour.rgb * (diffuse * diffuseColour).rgb + specularConstant * specularColour.rgb * specular, 1.0) * texture(tex, fs_in.tc);
	return output;
}

vec4 spotLight()
{
	// defines the size of the spotlight cone
	float outerCone = 0.95f;
	float innerCone = 0.97f;

	// diffusion
	vec3 normal = normalize(fs_in.normals);
	vec3 lightDirection = normalize(flashlightPosition - fs_in.vertex);
	float diffuse = max(dot(normal, lightDirection), 0.0f);

	// specular lighting
	vec3 viewDirection = normalize(cameraPosition - fs_in.vertex);
	vec3 reflectionDirection = reflect(-lightDirection, normal);
	float specAmount = pow(max(dot(viewDirection, reflectionDirection), 0.0f), shininessConstant);
	float specular = specAmount * specularConstant;

	// calculates the intensity of light relative to its angle to the cone
	float angle = dot(lightDirection, normalize(-flashlightDirection));
	float intensity = clamp((angle - outerCone) / (innerCone - outerCone), 0.0f, 1.0f);

	vec4 output = vec4(texture(tex, fs_in.tc) * (diffuse * intensity + ambientConstant) + texture(tex, fs_in.tc).r * specular * intensity) * vec4(1.0f);

	return output;
}

void main()
{
	vec4 directlight = dirLight();
	vec4 spotlight = spotLight();

	// update color values
	if (isFlashlightOn == 1){
		color = directlight + spotlight;
	}
	else{
		color = directlight;
	}
}