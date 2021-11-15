import math
from maya import cmds
from maya.api import OpenMaya, OpenMayaAnim

import dem_bones


db = dem_bones.DemBones()
db.compute("face_skinned", "face_shapes", start_frame=1001, end_frame=1052)

for frame in range(db.start_frame, db.end_frame + 1):
    for influence in db.influences:
        matrix = OpenMaya.MMatrix(db.anim_matrix(influence, frame))
        matrix = OpenMaya.MTransformationMatrix(matrix)
        translate = matrix.translation(OpenMaya.MSpace.kWorld)
        rotate = matrix.rotation().asVector()

        cmds.setKeyframe("{}.translateX".format(influence), time=frame, value=translate.x)
        cmds.setKeyframe("{}.translateY".format(influence), time=frame, value=translate.y)
        cmds.setKeyframe("{}.translateZ".format(influence), time=frame, value=translate.z)
        cmds.setKeyframe("{}.rotateX".format(influence), time=frame, value=math.degrees(rotate.x))
        cmds.setKeyframe("{}.rotateY".format(influence), time=frame, value=math.degrees(rotate.y))
        cmds.setKeyframe("{}.rotateZ".format(influence), time=frame, value=math.degrees(rotate.z))

sel = OpenMaya.MSelectionList()
sel.add("face_skinned_SK")
skin_cluster_obj = sel.getDependNode(0)
skin_cluster_fn = OpenMayaAnim.MFnSkinCluster(skin_cluster_obj)

sel = OpenMaya.MSelectionList()
sel.add("face_skinned")
mesh_dag = sel.getDagPath(0)
mesh_dag.extendToShape()

skin_cluster_fn.setWeights(
    mesh_dag,
    OpenMaya.MObject(),
    OpenMaya.MIntArray(range(len(db.influences))),
    OpenMaya.MDoubleArray(db.weights)
)
