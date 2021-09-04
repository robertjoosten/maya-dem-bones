# maya-dem-bones
[DemBones](https://github.com/electronicarts/dem-bones) python bindings for use in Maya.

## Installation
* Extract the content of the .rar file anywhere on disk.
* Compile python bindings for specific Maya versions.
* Drag the dem-bones.mel file in Maya to permanently install the script.

## Compiling
The compiling of the python bindings can be done on by running the build.bat 
command specifying the desired maya version. The build.bat scripts expects
both Maya and Visual studio to be installed in the default directory. If this
is not the case the build.bat file can be edited to make sure it links to 
files that exist on disk. Currently only windows is supported! Following the 
steps below will create a pyd file for the specified version of Maya in the 
build directory. As the build.bat builds an environment specific for the 
version of maya it is not possible to switch maya versions in the same 
terminal as the build will error.

1. Copy the following libraries to their respective folders in `/extern`:
    - [DemBones](https://github.com/electronicarts/dem-bones) with path `/extern/DemBones/DemBones/Dembones.h`,
    - [pybind11](https://github.com/pybind/pybind11) with path `/extern/pybind11/include/pybind11/pybind11.h`,
    - [Eigen 3.3.9](https://eigen.tuxfamily.org/) with path `/extern/Eigen/Eigen/Dense`,
 
2. Run build.bat
```
cd path/to/maya-dem-bones
build.bat 2022
```

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
import dem_bones

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
- Any build python bindings `/build` uses third party libraries: DemBones, pybind11 and Eigen with licenses in [3RDPARTYLICENSES.md](3RDPARTYLICENSES.md)