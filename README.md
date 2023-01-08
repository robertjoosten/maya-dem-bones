# maya-dem-bones
This repository contains Maya python bindings for [DemBones](https://github.com/electronicarts/dem-bones) 
an implementation of [Smooth Skinning Decomposition with Rigid Bones](http://binh.graphics/papers/2012sa-ssdr/), 
an automated algorithm to extract the *Linear Blend Skinning* (LBS) with bone 
transformations from a set of example meshes. *Skinning Decomposition* can be 
used in various tasks:
- converting any animated mesh sequence, e.g. geometry cache, to LBS, which can be replayed in popular game engines,
- solving skinning weights from shapes and skeleton poses, e.g. converting blendshapes to LBS,
- solving bone transformations for a mesh animation given skinning weights.

## Installation
Depending on the version of Maya you are using pip is either not installed
or is faulty. To make sure you have the latest version of pip installed 
run the following commands.

* curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
* <MAYAPY> get-pip.py

Once the latest version of pip has been ensured the repository can be cloned
and its submodules initialized. These submodules contain DemBones, Eigen and
pybind11.

* git clone https://github.com/robertjoosten/maya-dem-bones.git
* cd maya-dem-bones
* git submodule update --init --recursive
* <MAYAPY> -m pip install .

## Usage
The python bindings only provide partial mapping to the full capabilities of 
the [DemBones](https://github.com/electronicarts/dem-bones) project. It takes
a mesh with a skin cluster and compute the best possible weights and transforms
for the existing skeleton. It is possible to exclude weights via a `demLock`
color set and exclude transform calculation via a `demLock` boolean attribute 
on the influence. You can extend the functionality of the class by creating 
a subclass that will allow you to recreate the animation, drive the helper 
joints with an RBF network using the newly calculated matrices etc.

```python

from src import dem_bones

db = dem_bones.DemBones()
db.compute("skinned_MESH", "deformed_MESH", start_frame=1001, end_frame=1010)

print(db.influences)
print(db.weights)
print(db.bind_matrix("jaw_JNT"))
print(db.anim_matrix("jaw_JNT", 1005))
```

### Example
A maya and python file is provided in the `/example` directory. This maya file
contains two meshes and a skeleton. Both meshes are the standard face taken 
from Apple's ARKit. One of the meshes is driven by a blend shape node which 
has a shape triggered at each frame. The other is default bound to a skeleton.
After running the code contained in the python file the skin weights and joint
transformations will be calculated and set them in the scene to match the mesh
driven by the blend shape node.

## Licenses
- The source code, `/src`, uses *MIT* as detailed in [LICENSE.md](LICENSE.md)
- Any build python bindings uses third party libraries: DemBones, pybind11 and Eigen with licenses in [3RDPARTYLICENSES.md](3RDPARTYLICENSES.md)
