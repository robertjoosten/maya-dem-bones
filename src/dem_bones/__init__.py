import time
import logging
from maya import cmds
from maya.api import OpenMaya

from . import _core


__all__ = ["DemBones"]
log = logging.getLogger(__name__)


class DemBones(_core.DemBones):

    def compute(self, source, target, start_frame, end_frame):
        """
        :param str source:
        :param str target:
        :param int start_frame:
        :param int end_frame:
        """
        t = time.time()
        super(DemBones, self).compute(source, target, start_frame, end_frame)
        elapsed = time.time() - t

        err = self.rmse()
        log.info("Decomposed smooth skin weights for '{}' with an rmse of "
                 "{:.6f} in {:.3f} seconds.".format(source, err, elapsed))
