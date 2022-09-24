# Copyright (C) 2022 ThornCigar, All Rights Reserved.
#
# https://github.com/ThornCigar
#

import numpy as np
import pandas as pd


def mid_price_to_price_mat(s: pd.Series, dim: list):
    return s.to_numpy().reshape(dim[1], dim[0])
