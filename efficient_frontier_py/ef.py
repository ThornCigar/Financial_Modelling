# Copyright (C) 2022 ThornCigar, All Rights Reserved.
#
# https://github.com/ThornCigar
#

import numpy as np
import pandas as pd

import dataprocessing as efdp
import matrixcalculation as efmc

data_path = "all_stocks_5yr.csv"

if __name__ == '__main__':
    print("Starting...\n")

    # import data
    data = efdp.import_data(data_path)

    # prepare data & normalisation
    data, data_dim = efdp.prepare_data(data)
    data = efdp.add_mid_price_from_openclose(data)

    # convert to price matrix
    price_mat = efmc.mid_price_to_price_mat(data['mid'], data_dim)

    # calculate return matrix

    # min. var. portfolio using lagrange

    # plot (?)

    # testing linear combination

    # plot (?)

    print("\nFinished.")
