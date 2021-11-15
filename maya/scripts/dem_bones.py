import time
import logging
from maya import cmds
from maya.api import OpenMaya

try:
    import _dem_bones
except ImportError:
    raise ImportError("Unable to import python bindings for '{}'.".format(__name__))


__all__ = ["DemBones"]
log = logging.getLogger(__name__)


class DemBones(_dem_bones.DemBones):

    def compute(self, source, target, start_frame, end_frame):
        """
        :param str source:
        :param str target:
        :param int start_frame:
        :param int end_frame:
        """
        t = time.clock()
        super(DemBones, self).compute(source, target, start_frame, end_frame)
        elapsed = time.clock() - t

        err = self.rmse()
        log.info("Decomposed smooth skin weights for '{}' with an rmse of "
                 "{:.6f} in {:.3f} seconds.".format(source, err, elapsed))
