
# Interactive

## Importing Models
The original model files used for this section are stored in `\Render\Models_Final`, each was opened in Blender, selected, and exported as glTF. The following export settings were used:
- Format : glTF Seperate ( .glTF + .bin + textures)
- Include:
	- Limit To: Selected Objects
	- Data: Custom Properties
- Geometry -> Mesh
	- Apply Modifiers
	- UVs
	- Normals
	- Tangents
	- Vertex Colors

All remaining kept as default before finalizing the export.
After loading the exported file into the openGL project, it was found that the glTF loader function provided for this project did not support models with multiple textures and instead took the texture stored at index 0 within the glTF file. Models imported this way would have incorrect textures and often missing geometry. To avoid an extensive rewrite of the project infrastructure, this problem was circumvented by baking model textures into a single texture file. 

### Texture Baking
Texture baking describes the process to which rays are cast towards a model to record its surface detail, which can then be projected onto a 2D image texture. This is useful for exporting models either with multiple textures or dynamic textures to an environment which does not natively support it.

To bake textures with an existing UV map, we must first create a new one specifically for baking, this can be done via the `Object Data Properties` tab on the right-hand side of blender. Upon adding a new UV map, ensure it is selected however also make sure the *camera icon* is deselected otherwise the model textures will be mapped to the new UV map.

To generate a new UV map, we first enter `Edit Mode`, select all vertices -> UV tab -> Smart UV Project. This automatically projects all geometry into a UV with the aim of keeping face overlapping at a minimum, this can be double checked within the `UV editor`.

Next, we define the image texture we want to bake to, this can be done within the `UV editor` by selecting Image -> new Image, for this project, 4k textures were used with a black background for most, but a clear background for the tree model due to branch textures containing a transparent background.

To choose the materials required for baking, under each material, an image texture node must be created. To do this, in the shader editor, under the correct texture name, press shift + A, then search 'Image Texture' then add to the editor. In each material section, the output image to bake to must be selected.

While the image texture nodes are still selected, the baking settings must be configured within the `Render Properties` section in the right-hand side of blender. Here we must define *Cycles* as our render output, and also *GPU Compute* as the device if applicable (will drastically reduce baking time). Below in the same section, baking settings can be configured, here, the *Bake Type* should be set to Diffuse, and direct/indirect lighting should be deselected as we do not want to bake blenders lighting into the model. Once ready, the bake button can be pressed and the image will start baking, the output will look something like the image below:

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Scene/assets/textures/campfirebake.png?raw=true)
Once a final baked texture has been produced, the old UV maps and materials can be deleted, instead using only one material mapping to the baked image. Once this has been completed, the model can be re-exported to the openGL application to which all texture/geometry issues should be resolved.

## Setting up the scene
As it seemed although the provided code was designed for one singular model due to lack of support for multiple models and modifying individual model translations, the final scene composition was created within Blender itself. All baked models were translated and rotated into their positions and all transforms applied by navigating to Object -> Apply -> Apply All Transforms, meaning when they are exported, their positions will be saved. It should be noted that for this step, a flat grass plane was added to the scene, this does not exist as one of the primary modeled objects and instead just serves as a floor for the scene.

To import multiple models into the openGL project, we first convert the Content declaration to an array:
`Content  content[5]; // Add array of content loaders (+drawing)`
Next, each element in this array must be drawn in the *render()* function, upon first try, it was found that with the introduction of new models, the texture ID gets re-mapped to the last loaded mesh. To overcome this issue, before each model gets drawn, its texture is re-mapped back to its correct index, in this case they can be represented by GLuint values 1-5. This code looks as follows:
`glBindTexture(GL_TEXTURE_2D, texture);  // Where texture is a GLuint index`
Upon completion of these steps, the rendered results looks as follows:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneNoLighting.JPG?raw=true)
## Lighting

Lights in this project simply come in the form of 3D vectors which are sent to the fragment shader in the form of uniform variables. Each light contains its own variables to control the base colour, diffuse colour, and specular colour, as well as constants to control the intensity of ambient lighting, diffuse lighting and specular lighting. These variables are also sent to the fragment shader to determine the output colour. 

In this project the vertex shader was left unchanged, however a new fragment shader was created to light the scene. The fragment shader provides support for direct lights by calculating the diffuse and specular values of a fragment and multiplying them by the product of their related colour vectors and constants to produce a new 4D colour vector. Initially, this output produced the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneLighting.JPG?raw=true)
Upon tweaking the light colour and light constants, we can come to a closer representation of the renders in past sections of this coursework with the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneTweakedLighting.JPG?raw=true)
Additionally, a spot light was implemented within the fragment shader to simulate the use of a flashlight, it is tied to the position and direction of the camera, and can be toggled on or off using the F key. Key presses are recorded and sent as a uniform variable to the shader where it can read the input and enable/disable the spotlight on demand. The spotlight primarily works the same way as the direct light, however its intensity is confined within the bounds of its cone which is defined within the shader. To display both lights at the same time, it is as simple as finding the sum of both of both 4D vectors and assigning it to the colour.

## Interactivity

Initially, this project contained a semi-locked camera and the ability to rotate the model itself using the arrow keys. Since the idea of this project was to display multiple objects, model rotation was removed, instead replaced with free camera movement. 

There existed some functionality for zooming in and out towards the object at the origin point, however this just incremented the x and z values depending on if the W or S keys were pressed, and would not always logically move 'forward' if the camera were pointed in a different direction. To solve this, we can simply add or subtract the product of the *cameraSpeed* constant with the front unit-vector of the camera. This allows us to move 'forward' relative to our camera position rather than relative to the world axis. Additionally, the keys A and D were mapped to move left or right relative to the camera position, similarly, this was achieved by adding or subtracting the product of the camera speed and some direction unit-vector. In this case the direction unit-vector is the normalized cross product of the cameras front vector and up vector, which calculates the vector perpendicular to 2 vectors.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cross_product_vector.svg/1200px-Cross_product_vector.svg.png)(source: https://en.wikipedia.org/wiki/Cross_product)

As shown above, if we know vectors A and B, we can find perpendicular vector A X B by calculating the cross product of A and B.

Additionally, functionality was added so the user can travel up or down the y-axis using keys CTRL and SPACE, although this requires no more math than incrementing and decrementing the camera y-values.

The code for this functionality is as follows:
`if (keyStatus[GLFW_KEY_W]) cameraPosition  +=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_S]) cameraPosition  -=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_A]) cameraPosition  -=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_D]) cameraPosition  +=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_SPACE]) cameraPosition.y += cameraSpeed;`
`if (keyStatus[GLFW_KEY_LEFT_CONTROL]) cameraPosition.y -= cameraSpeed;`

What is left is to allow the user to rotate the camera, for this, similar to other 3D graphics platforms like blender, the mouse can be used to rotate the camera. In this case by holding the left mouse button. This was achieved by centering the mouse on the screen on the first click, and rotating the camera based on the mouse position offset from the center. Calculating the mouse offset is as follows:

`float  xOffset = cameraRotateSensitivity * (float)(mouseY - (windowHeight / 2)) / windowHeight;`
`float  yOffset = cameraRotateSensitivity * (float)(mouseX - (windowWidth / 2)) / windowWidth;`

The rotation is calculated using the glm library function *rotate()*, which takes the origin point, angle expressed in radians, and the axis of rotation as parameters. This must be calculated for both horizontal and vertical rotation and can be written as follows:

`// calculate vertical camera rotation`
`glm::vec3  frontVector = glm::rotate(cameraFront, glm::radians(-xOffset), glm::normalize(glm::cross(cameraFront, cameraUp)));`

`// apply horizontal rotation
cameraFront  =  glm::rotate(cameraFront, glm::radians(-yOffset), cameraUp);`

To prevent the camera from rotating past 180 degrees, vertical rotation only happens when the camera is pointing below a certain range.

Lastly, the interaction of the flashlight mentioned in the lighting section was implemented to allow the user to more dynamically interact with the scene, it is toggled using the F key, which triggers a change in the variable `isFlashlightOn` which is sent as a uniform variable to the fragment shader every iteration of the `render()` method. Since GLFW doesn't register any delay between key presses by default, similar to the mouse movement, we first need to register if the key is already down before triggering this key press event, without this, the event will get triggered several times per key press making the function otherwise useless. Below is an image of the flashlight in use:

# Interactive

## Importing Models
The original model files used for this section are stored in `\Render\Models_Final`, each was opened in Blender, selected, and exported as glTF. The following export settings were used:
- Format : glTF Seperate ( .glTF + .bin + textures)
- Include:
	- Limit To: Selected Objects
	- Data: Custom Properties
- Geometry -> Mesh
	- Apply Modifiers
	- UVs
	- Normals
	- Tangents
	- Vertex Colors

All remaining kept as default before finalizing the export.
After loading the exported file into the openGL project, it was found that the glTF loader function provided for this project did not support models with multiple textures and instead took the texture stored at index 0 within the glTF file. Models imported this way would have incorrect textures and often missing geometry. To avoid an extensive rewrite of the project infrastructure, this problem was circumvented by baking model textures into a single texture file. 

### Texture Baking
Texture baking describes the process to which rays are cast towards a model to record its surface detail, which can then be projected onto a 2D image texture. This is useful for exporting models either with multiple textures or dynamic textures to an environment which does not natively support it.

To bake textures with an existing UV map, we must first create a new one specifically for baking, this can be done via the `Object Data Properties` tab on the right-hand side of blender. Upon adding a new UV map, ensure it is selected however also make sure the *camera icon* is deselected otherwise the model textures will be mapped to the new UV map.

To generate a new UV map, we first enter `Edit Mode`, select all vertices -> UV tab -> Smart UV Project. This automatically projects all geometry into a UV with the aim of keeping face overlapping at a minimum, this can be double checked within the `UV editor`.

Next, we define the image texture we want to bake to, this can be done within the `UV editor` by selecting Image -> new Image, for this project, 4k textures were used with a black background for most, but a clear background for the tree model due to branch textures containing a transparent background.

To choose the materials required for baking, under each material, an image texture node must be created. To do this, in the shader editor, under the correct texture name, press shift + A, then search 'Image Texture' then add to the editor. In each material section, the output image to bake to must be selected.

While the image texture nodes are still selected, the baking settings must be configured within the `Render Properties` section in the right-hand side of blender. Here we must define *Cycles* as our render output, and also *GPU Compute* as the device if applicable (will drastically reduce baking time). Below in the same section, baking settings can be configured, here, the *Bake Type* should be set to Diffuse, and direct/indirect lighting should be deselected as we do not want to bake blenders lighting into the model. Once ready, the bake button can be pressed and the image will start baking, the output will look something like the image below:

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Scene/assets/textures/campfirebake.png?raw=true)
Once a final baked texture has been produced, the old UV maps and materials can be deleted, instead using only one material mapping to the baked image. Once this has been completed, the model can be re-exported to the openGL application to which all texture/geometry issues should be resolved.

## Setting up the scene
As it seemed although the provided code was designed for one singular model due to lack of support for multiple models and modifying individual model translations, the final scene composition was created within Blender itself. All baked models were translated and rotated into their positions and all transforms applied by navigating to Object -> Apply -> Apply All Transforms, meaning when they are exported, their positions will be saved. It should be noted that for this step, a flat grass plane was added to the scene, this does not exist as one of the primary modeled objects and instead just serves as a floor for the scene.

To import multiple models into the openGL project, we first convert the Content declaration to an array:
`Content  content[5]; // Add array of content loaders (+drawing)`
Next, each element in this array must be drawn in the *render()* function, upon first try, it was found that with the introduction of new models, the texture ID gets re-mapped to the last loaded mesh. To overcome this issue, before each model gets drawn, its texture is re-mapped back to its correct index, in this case they can be represented by GLuint values 1-5. This code looks as follows:
`glBindTexture(GL_TEXTURE_2D, texture);  // Where texture is a GLuint index`
Upon completion of these steps, the rendered results looks as follows:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneNoLighting.JPG?raw=true)
## Lighting

Lights in this project simply come in the form of 3D vectors which are sent to the fragment shader in the form of uniform variables. Each light contains its own variables to control the base colour, diffuse colour, and specular colour, as well as constants to control the intensity of ambient lighting, diffuse lighting and specular lighting. These variables are also sent to the fragment shader to determine the output colour. 

In this project the vertex shader was left unchanged, however a new fragment shader was created to light the scene. The fragment shader provides support for direct lights by calculating the diffuse and specular values of a fragment and multiplying them by the product of their related colour vectors and constants to produce a new 4D colour vector. Initially, this output produced the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneLighting.JPG?raw=true)
Upon tweaking the light colour and light constants, we can come to a closer representation of the renders in past sections of this coursework with the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneTweakedLighting.JPG?raw=true)
Additionally, a spot light was implemented within the fragment shader to simulate the use of a flashlight, it is tied to the position and direction of the camera, and can be toggled on or off using the F key. Key presses are recorded and sent as a uniform variable to the shader where it can read the input and enable/disable the spotlight on demand. The spotlight primarily works the same way as the direct light, however its intensity is confined within the bounds of its cone which is defined within the shader. To display both lights at the same time, it is as simple as finding the sum of both of both 4D vectors and assigning it to the colour.

## Interactivity

Initially, this project contained a semi-locked camera and the ability to rotate the model itself using the arrow keys. Since the idea of this project was to display multiple objects, model rotation was removed, instead replaced with free camera movement. 

There existed some functionality for zooming in and out towards the object at the origin point, however this just incremented the x and z values depending on if the W or S keys were pressed, and would not always logically move 'forward' if the camera were pointed in a different direction. To solve this, we can simply add or subtract the product of the *cameraSpeed* constant with the front unit-vector of the camera. This allows us to move 'forward' relative to our camera position rather than relative to the world axis. Additionally, the keys A and D were mapped to move left or right relative to the camera position, similarly, this was achieved by adding or subtracting the product of the camera speed and some direction unit-vector. In this case the direction unit-vector is the normalized cross product of the cameras front vector and up vector, which calculates the vector perpendicular to 2 vectors.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cross_product_vector.svg/1200px-Cross_product_vector.svg.png)(source: https://en.wikipedia.org/wiki/Cross_product)

As shown above, if we know vectors A and B, we can find perpendicular vector A X B by calculating the cross product of A and B.

Additionally, functionality was added so the user can travel up or down the y-axis using keys CTRL and SPACE, although this requires no more math than incrementing and decrementing the camera y-values.

The code for this functionality is as follows:
`if (keyStatus[GLFW_KEY_W]) cameraPosition  +=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_S]) cameraPosition  -=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_A]) cameraPosition  -=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_D]) cameraPosition  +=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_SPACE]) cameraPosition.y += cameraSpeed;`
`if (keyStatus[GLFW_KEY_LEFT_CONTROL]) cameraPosition.y -= cameraSpeed;`

What is left is to allow the user to rotate the camera, for this, similar to other 3D graphics platforms like blender, the mouse can be used to rotate the camera. In this case by holding the left mouse button. This was achieved by centering the mouse on the screen on the first click, and rotating the camera based on the mouse position offset from the center. Calculating the mouse offset is as follows:

`float  xOffset = cameraRotateSensitivity * (float)(mouseY - (windowHeight / 2)) / windowHeight;`
`float  yOffset = cameraRotateSensitivity * (float)(mouseX - (windowWidth / 2)) / windowWidth;`

The rotation is calculated using the glm library function *rotate()*, which takes the origin point, angle expressed in radians, and the axis of rotation as parameters. This must be calculated for both horizontal and vertical rotation and can be written as follows:

`// calculate vertical camera rotation`
`glm::vec3  frontVector = glm::rotate(cameraFront, glm::radians(-xOffset), glm::normalize(glm::cross(cameraFront, cameraUp)));`

`// apply horizontal rotation
cameraFront  =  glm::rotate(cameraFront, glm::radians(-yOffset), cameraUp);`

To prevent the camera from rotating past 180 degrees, vertical rotation only happens when the camera is pointing below a certain range.

Lastly, the interaction of the flashlight mentioned in the lighting section was implemented to allow the user to more dynamically interact with the scene, it is toggled using the F key, which triggers a change in the variable `isFlashlightOn` which is sent as a uniform variable to the fragment shader every iteration of the `render()` method. Since GLFW doesn't register any delay between key presses by default, similar to the mouse movement, we first need to register if the key is already down before triggering this key press event, without this, the event will get triggered several times per key press making the function otherwise useless. Below is an image of the flashlight in use:

# Interactive

## Importing Models
The original model files used for this section are stored in `\Render\Models_Final`, each was opened in Blender, selected, and exported as glTF. The following export settings were used:
- Format : glTF Seperate ( .glTF + .bin + textures)
- Include:
	- Limit To: Selected Objects
	- Data: Custom Properties
- Geometry -> Mesh
	- Apply Modifiers
	- UVs
	- Normals
	- Tangents
	- Vertex Colors

All remaining kept as default before finalizing the export.
After loading the exported file into the openGL project, it was found that the glTF loader function provided for this project did not support models with multiple textures and instead took the texture stored at index 0 within the glTF file. Models imported this way would have incorrect textures and often missing geometry. To avoid an extensive rewrite of the project infrastructure, this problem was circumvented by baking model textures into a single texture file. 

### Texture Baking
Texture baking describes the process to which rays are cast towards a model to record its surface detail, which can then be projected onto a 2D image texture. This is useful for exporting models either with multiple textures or dynamic textures to an environment which does not natively support it.

To bake textures with an existing UV map, we must first create a new one specifically for baking, this can be done via the `Object Data Properties` tab on the right-hand side of blender. Upon adding a new UV map, ensure it is selected however also make sure the *camera icon* is deselected otherwise the model textures will be mapped to the new UV map.

To generate a new UV map, we first enter `Edit Mode`, select all vertices -> UV tab -> Smart UV Project. This automatically projects all geometry into a UV with the aim of keeping face overlapping at a minimum, this can be double checked within the `UV editor`.

Next, we define the image texture we want to bake to, this can be done within the `UV editor` by selecting Image -> new Image, for this project, 4k textures were used with a black background for most, but a clear background for the tree model due to branch textures containing a transparent background.

To choose the materials required for baking, under each material, an image texture node must be created. To do this, in the shader editor, under the correct texture name, press shift + A, then search 'Image Texture' then add to the editor. In each material section, the output image to bake to must be selected.

While the image texture nodes are still selected, the baking settings must be configured within the `Render Properties` section in the right-hand side of blender. Here we must define *Cycles* as our render output, and also *GPU Compute* as the device if applicable (will drastically reduce baking time). Below in the same section, baking settings can be configured, here, the *Bake Type* should be set to Diffuse, and direct/indirect lighting should be deselected as we do not want to bake blenders lighting into the model. Once ready, the bake button can be pressed and the image will start baking, the output will look something like the image below:

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Scene/assets/textures/campfirebake.png?raw=true)
Once a final baked texture has been produced, the old UV maps and materials can be deleted, instead using only one material mapping to the baked image. Once this has been completed, the model can be re-exported to the openGL application to which all texture/geometry issues should be resolved.

## Setting up the scene
As it seemed although the provided code was designed for one singular model due to lack of support for multiple models and modifying individual model translations, the final scene composition was created within Blender itself. All baked models were translated and rotated into their positions and all transforms applied by navigating to Object -> Apply -> Apply All Transforms, meaning when they are exported, their positions will be saved. It should be noted that for this step, a flat grass plane was added to the scene, this does not exist as one of the primary modeled objects and instead just serves as a floor for the scene.

To import multiple models into the openGL project, we first convert the Content declaration to an array:
`Content  content[5]; // Add array of content loaders (+drawing)`
Next, each element in this array must be drawn in the *render()* function, upon first try, it was found that with the introduction of new models, the texture ID gets re-mapped to the last loaded mesh. To overcome this issue, before each model gets drawn, its texture is re-mapped back to its correct index, in this case they can be represented by GLuint values 1-5. This code looks as follows:
`glBindTexture(GL_TEXTURE_2D, texture);  // Where texture is a GLuint index`
Upon completion of these steps, the rendered results looks as follows:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneNoLighting.JPG?raw=true)
## Lighting

Lights in this project simply come in the form of 3D vectors which are sent to the fragment shader in the form of uniform variables. Each light contains its own variables to control the base colour, diffuse colour, and specular colour, as well as constants to control the intensity of ambient lighting, diffuse lighting and specular lighting. These variables are also sent to the fragment shader to determine the output colour. 

In this project the vertex shader was left unchanged, however a new fragment shader was created to light the scene. The fragment shader provides support for direct lights by calculating the diffuse and specular values of a fragment and multiplying them by the product of their related colour vectors and constants to produce a new 4D colour vector. Initially, this output produced the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneLighting.JPG?raw=true)
Upon tweaking the light colour and light constants, we can come to a closer representation of the renders in past sections of this coursework with the following render:
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Interactive/Screencaps/SceneTweakedLighting.JPG?raw=true)
Additionally, a spot light was implemented within the fragment shader to simulate the use of a flashlight, it is tied to the position and direction of the camera, and can be toggled on or off using the F key. Key presses are recorded and sent as a uniform variable to the shader where it can read the input and enable/disable the spotlight on demand. The spotlight primarily works the same way as the direct light, however its intensity is confined within the bounds of its cone which is defined within the shader. To display both lights at the same time, it is as simple as finding the sum of both of both 4D vectors and assigning it to the colour.

## Interactivity

Initially, this project contained a semi-locked camera and the ability to rotate the model itself using the arrow keys. Since the idea of this project was to display multiple objects, model rotation was removed, instead replaced with free camera movement. 

There existed some functionality for zooming in and out towards the object at the origin point, however this just incremented the x and z values depending on if the W or S keys were pressed, and would not always logically move 'forward' if the camera were pointed in a different direction. To solve this, we can simply add or subtract the product of the *cameraSpeed* constant with the front unit-vector of the camera. This allows us to move 'forward' relative to our camera position rather than relative to the world axis. Additionally, the keys A and D were mapped to move left or right relative to the camera position, similarly, this was achieved by adding or subtracting the product of the camera speed and some direction unit-vector. In this case the direction unit-vector is the normalized cross product of the cameras front vector and up vector, which calculates the vector perpendicular to 2 vectors.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Cross_product_vector.svg/1200px-Cross_product_vector.svg.png)(source: https://en.wikipedia.org/wiki/Cross_product)

As shown above, if we know vectors A and B, we can find perpendicular vector A X B by calculating the cross product of A and B.

Additionally, functionality was added so the user can travel up or down the y-axis using keys CTRL and SPACE, although this requires no more math than incrementing and decrementing the camera y-values.

The code for this functionality is as follows:
`if (keyStatus[GLFW_KEY_W]) cameraPosition  +=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_S]) cameraPosition  -=  cameraSpeed  *  cameraFront;`
`if (keyStatus[GLFW_KEY_A]) cameraPosition  -=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_D]) cameraPosition  +=  cameraSpeed  *  glm::normalize(glm::cross(cameraFront, cameraUp));`
`if (keyStatus[GLFW_KEY_SPACE]) cameraPosition.y += cameraSpeed;`
`if (keyStatus[GLFW_KEY_LEFT_CONTROL]) cameraPosition.y -= cameraSpeed;`

What is left is to allow the user to rotate the camera, for this, similar to other 3D graphics platforms like blender, the mouse can be used to rotate the camera. In this case by holding the left mouse button. This was achieved by centering the mouse on the screen on the first click, and rotating the camera based on the mouse position offset from the center. Calculating the mouse offset is as follows:

`float  xOffset = cameraRotateSensitivity * (float)(mouseY - (windowHeight / 2)) / windowHeight;`
`float  yOffset = cameraRotateSensitivity * (float)(mouseX - (windowWidth / 2)) / windowWidth;`

The rotation is calculated using the glm library function *rotate()*, which takes the origin point, angle expressed in radians, and the axis of rotation as parameters. This must be calculated for both horizontal and vertical rotation and can be written as follows:

`// calculate vertical camera rotation`
`glm::vec3  frontVector = glm::rotate(cameraFront, glm::radians(-xOffset), glm::normalize(glm::cross(cameraFront, cameraUp)));`

`// apply horizontal rotation
cameraFront  =  glm::rotate(cameraFront, glm::radians(-yOffset), cameraUp);`

To prevent the camera from rotating past 180 degrees, vertical rotation only happens when the camera is pointing below a certain range.

Lastly, the interaction of the flashlight mentioned in the lighting section was implemented to allow the user to more dynamically interact with the scene, it is toggled using the F key, which triggers a change in the variable `isFlashlightOn` which is sent as a uniform variable to the fragment shader every iteration of the `render()` method. Since GLFW doesn't register any delay between key presses by default, similar to the mouse movement, we first need to register if the key is already down before triggering this key press event, without this, the event will get triggered several times per key press making the function otherwise useless. Below is an image of the flashlight in use:
