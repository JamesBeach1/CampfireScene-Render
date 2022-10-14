
# Render

## Models

### Tree
##### V1
Starting with the base cube, a single loop cut was added down the middle and each side distorted to form a hexagon. The main face was then extruded upwards several times with slight changes in direction to simulate a trees natural imperfections.

Each face of the loop cut was then extruded upwards with a more exaggerated change in angle to split the tree in two and create branches. Additional loop cuts were used on those branches to extrude additional branches. 
##### V2
The main tree shape was given a subdivision surface modifier and a basic material was added with a solid brown colour.
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V2/Tree/DevelopmentScreencap1.JPG?raw=true)
##### V3
A cylinder projection was made on the base of the tree to form a UV map, a texture (available in appendices section) was then applied and scaled to fit the tree's scale.
##### V4
A vertex group is created and branches and painted using vertex paint mode to specify where leaves will be placed. A particle hair system is then added using a branch texture (available in appendices) as the object, it is then assigned the created vertex group and modified to taste. This includes changes to scale and Z rotation.

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_Final/Tree/render.png?raw=true)  

### Log
##### V1
Starting with a cylinder, 2 loop cuts are made and each side is slightly distorted. On each end, the face is selected and a smaller selection is made to separate the bark from the inside of the tree, this face is then pushed slightly inward to create the effect of broken bark extruding out. Individual vertices were then pulled out and distorted to amplify this effect.
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V1/Log/DevelopmentScreencap1.JPG?raw=true)

Entering sculpt mode, smaller imperfections were then added both in the lengthwise direction of the bark, and in a swirling motion on each of the ends. Using the pull tool of the sculpt mode, a broken branch is then extruded from the bark.
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V1/Log/DevelopmentScreencap2.JPG?raw=true)

##### V2
A solid brown material is added to the log
##### V3
A cylinder projection is used to create a UV map of the log, a texture (available in appendices) is then placed on the bark of the log and sized using the UV editor. Additionally, the faces of each end of the log are selected and projected from view, another texture (available in appendices) is added to these faces and resized to fit.
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V3/Log/DevelopmentScreencap1.JPG?raw=true)
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_Final/Log/render.png?raw=true)
  

### Campfire
##### V1
For each rock, a cube was used, a subdivision surface modifier was used for each followed by a displacement modifier. For the displacement modifier, a voronoi texture was used, after toning down the size and intensity of this effect, we are left with a fairly convincing looking rock. Setting the coordinates field of the modifier to global means the effect of the displacement can be determined by its global xyz coordinates, this means the rock can be copy pasted and produce a new mesh each time without the need of manual tweaking.

The logs were just created by adding low poly cylinders followed by beveling the edges, they are then manually rotated into a convincing position.

##### V2
3 materials are produced, rock, gravel and wood. For each of these materials, thanks to the resources available at ambientcg, each contains a texture, normal map, roughness map and displacement map which are added using the relevant nodes in the shader editor. This allows us to simulate certain geometry such as bumps and scratches in the render without needing a high poly model to do so.  

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V2/Campfire/DevelopmentScreencap1.JPG?raw=true)
![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V2/Campfire/render.png?raw=true)

Each object in the scene, the logs, the floor, and the rocks are assigned those materials.
  

### Woodcutters Axe
##### V1
A reference image of an axe was placed in the editor and rotated so the handle points directly upwards. Initially, a cube was used to trace the height of the handle, loop cuts and the manual addition of vertices were used to trace the geometry of the handle. The edges were then beveled with an appropriate number of  segments.

![Early axe trace](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V1/Axe/DevelopmentScreencap.JPG?raw=true)

The finished handle was then moved out of the way and the same process was performed on the axe head, manual scaling of the vertices was used to produce the fine point, beveling was used to round out the bottom of the head.

![Finished axe trace](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V1/Axe/DevelopmentScreencap2.JPG?raw=true)

##### V2
Both the head and handle of the axe were given materials. Each with a texture (available in appendices), normal map, displacement map and roughness map to simulate more complex geometry. For this, the head was projected from view to create a UV map, the handle was projected as a cylinder. Both pieces of the axe were then positioned together and joined as a single object.

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_V2/Axe/DevelopmentScreencap1.JPG?raw=true)
  ![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Models_Final/Axe/render.png?raw=true)

## Render Method

### Scene
##### Ground
A plane is subdivided by ~60 levels and lightly distorted on each side, a displacement modifier is added using a cloud noise map as the texture to produce bumps and grooves. The displacement strength is then wildly lowered to produce a more realistic landscape. A basic top down grass texture is then added using a material, no displacement maps etc are needed here since the grass particles obstruct any view of the ground underneath.

##### Grass
A vertex group is created and painted on the ground plane using the weight paint mode to help optimise the area, only areas visible to the camera are painted. 
A hair particle system is then added to the ground plane and the above vertex group is set. the plane initially contains 30,000 particles, edited appropriately to mimic the look of grass. Each blade of grass also contains child nodes, each pointing outwards from the parent, this is used to simulate the look of tufts of grass grouped together. Additionally, a brownian force is applied to the grass to create a little bit of chaos and make the grass less uniform.
 
##### Lighting
Using the shader editor, the world is given a pitch black background colour meaning the only light visible in the render has to come from a light source I added to the scene, this is useful as the scene is meant to represent a dark forest lit only by campfire.

As this part of the project is only an offline render, with animations being created in another program, I instead decided to simply add an orange light within the campfire object to simulate the glow of a fire.

##### Objects
The scene is focused primarily on the campfire, front and center, acting as a light source for the rest of the scene. Trees are sprawled out into the background to give the scene some depth, especially the 3 trees in the background which are poorly lit, there to make the scene more 3-dimensional. 
Behind the fire is the log and axe, the axe was carefully rotated to ensure that the light caught the head correctly as it was very easy for the head to appear too dark to see in the final render.

![](https://github.com/JamesBeach1/CampfireScene-Render/blob/main/Render/Final_Render.png?raw=true)
