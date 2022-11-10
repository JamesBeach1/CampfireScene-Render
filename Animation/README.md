# Animation

## Exporting from Blender

Models were exported using the following steps:
- Select model to be exported
- If the model contains particle effects (in this case the tree model uses a particle effect for leaves), enter modifiers tab and press "Make instances real" under the particle system modifier to add all particle instances to the base model(so it isn't blender specific).
- If the model contains any non principle shader nodes such as glossy bsdf (the axe head as an example), swap this out for a principled bsdf shader node. Unreal Engine seems to have issues importing other materials.
- Navigate to file -> export -> FBX(.fbx)
- Ensure path mode is set to "copy" and the button directly to the right is enabled to embed textures
- Click "selected objects" under the "Limit to" label
- Under the geometry tab, set smoothing to "face"
- Click "Export FBX"

## Importing to Unreal Engine 5

Models were imported to Unreal Engine 5 using the following steps:
- Open content drawer
- Drag .fbx file into content drawer
- Click build nanite for models without textures with transparent backgrounds, doing so results in a black mask surrounding the texture
- Under "Material Import Method", click "Create new materials"
- Click "Import All"

In the case of the models in this project, normal maps were automatically mapped to the wrong property. To fix this, double click on the affected material to open the material editor and drag a line from the normal maps RGB property to the materials "normal" property.

## Creating the scene

### Adding lights to the scene

In the content drawer, under the engine folder, a default sky sphere "BP_Sky_Sphere" is searched and dragged into the scene to produce a light background. Under the sky sphere properties, "Colors determined by sun position" is unchecked, this is due to the sun emitting too much light for the scene over the horizon, unchecking this allows us more control over the colour of the sky.
Since we want to emulate the scene depicted in the offline render, the zenith and horizon colours are set to very dark blue/black and the stars brightness is turned down low. For the sake of development these colours were set brighter until there was a campfire to light the scene.

### Sculpting the landscape

Under landscape mode, a new landscape is created and applied to the scene, from here we can enter sculpt mode and begin shaping the scene. Since this scene is just consisting of hills and grooves, the sculpt tool is all we need, hills surround the landscape with a flat patch in the middle for our objects to sit in.

### Landscape textures

Firstly, ground textures were imported from Quixel Megascans assets, this was done by opening the content drawer and navigating to 'Add -> Add Quixel Content'. The textures 'Forest_Floor' and 'Rocky_Wild_Grass' were downloaded and added to the project, additionally, in the 3D Plants section, the 'Grass_Clumps' asset was downloaded and added to the project.

Secondly, a new material is created in the project files to use for the ground material. In the material editor of the new material, each of the downloaded textures are dragged in and connected to their own material attributes node, the outputs of both material attributes nodes are then connected to a layer blend node, this is what allows us to use multiple textures under one material. Additionally, the tile scaling of each texture is adjusted by multiplying a texCoord node by some arbitrary parameter and attaching the result to the UV input of the texture, this is iterated until a suitable texture scale is found.

In order to automatically sprinkle the 3D plant assets across our level, we can add a LandScapeGrassType object to the scene. This can be found by opening the content drawer, right click and navigate to 'Foliage -> LandscapeGrassType'. Opening the properties of this object allows us to add array elements, to which we add 1 for every 3D plant from the Grass_Clumps asset, each asset is then dragged into the 'Grass Mesh' box. A new layer should be added to the layer blend followed by a layer sample node connected to the LandscapeGrassType object, this allows us to paint Grass_Clumps into our scene using Landscape Mode.

### Fire Particle System

In order to simulate fire for the campfire model, a particle system was used, the method used to create this was sourced from the following tutorial: https://youtu.be/l2b9D7rtkKU.

To begin with, particle effects require a material to emit, so a new material is created and edited, this will be our fire. A texture sample node is added and given a noise texture, this is done by clicking on the sample and searching under the texture dropdown menu. Dynamic parameter nodes are used to store values for the tile multiplier, denisity, dissolve rate, temperature and saturation. Dynamic parameters provide the opportunity for us to edit values from within the particle system itself which allows for a more realistic, less uniform stream of textures.

The red channel of the noise texture is connected to a power node with the dissolve rate parameter set as the exponent, this causes the fire to glow a brighter red nearer the source of the flame and fade away at the perimeter. Additionally, the temperature parameter is connected to a BlackBody node, this relates to real life black-body radiation and allows us to more accurately represent the spectrum of colour that is emitted at certain temperatures.

Lastly, the resulting values are multiplied arbitrarily until a good looking result is made and is connected to the 'Emissive colour' property of the material attributes node.

To produce the particle system itself, a Niagara System must be added to the content drawer, this can be found by right clicking and navigating to 'FX -> Niagara System'. Upon creation, the 'fountain' engine should be selected.

Inside the Niagara System editor, particle size and lifetime are set under the properties of the 'Initialize Particle' section, these are adjusted until a satisfactory outcome is found in the preview screen on the left. Velocity is also tuned, specifically the 'Cone Axis' field is edited to change the angle of emission, this project uses a slight change on the x axis to simulate a light breeze of wind.

To access our material parameters, we press the green + icon next to 'particle update' and search for 'Dynamic Material Parameters'. Density, Dissolve rate and Saturation are edited manually to taste, for temperature, the down arrow is clicked and a 'Float from Curve' system is added, this allows us to lower a particles temperature throughout it's lifetime meaning the BlackBody node can give it a new colour.

Additionally, since we need the campfire to emit its own light to brighten the scene, we add a light renderer to the particle system, this is done by clicking the green + sign next to the 'render' and searching for 'Light Renderer'. In its properties, we can change it's radius scale to determine how far the light reaches, as well as the colour it emits, as a fire, we emit primarily red light with a touch of green to produce an orange glow. It is important that when using a light renderer that we keep the emitter spawn rate to a reasonable level as each particle produces its own light, not doing this has a significant effect on performance.

### Adding a camera sequence

Firstly, we add a master sequence to the scene, this can be done by navigating to the level sequence button in the header of the program followed by 'Add Master Sequence'. After creating and opening our master sequence, delete all other shots automatically created and stretch out both the sequence and the remaining shot to the desired length.

To create our initial camera position we click on the 'CineCameraActor' object and pilot it manually to the desired cinematic position, followed by clicking the beginning of the sequence and clicking the circular button next to the 'transform' menu. This creates our first keyframe in the sequence, next we can do the same thing to determine the final position of our camera. Once the camera is in your desired final position, click somewhere near the end of the sequence, preferably with a gap so the camera can come to a rest and press the circular button next to the transform section again to create the next keyframe. Now, the sequence should create a path for the camera to follow upon playing back the sequence, this can be viewed either by manually scrubbing through the timeline or pressing the play button in the bottom left of the screen. 

Finally, click the clipboard button labelled 'Render this movie to a video, or image frame sequence' to render our sequence to a video file.