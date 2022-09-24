# Copyright (C) 2022 ThornCigar, All Rights Reserved.
#
# https://github.com/ThornCigar
#

import pandas as pd


# Import csv from path p.
def import_data(p: str) -> pd.DataFrame:
    return pd.read_csv(p, delimiter=',')


# Trim DataFrame d.
# Clear stocks with different number of price entries and clear stocks with N/A
# values.
# Return a list: [data, data_dimensions]
def prepare_data(d: pd.DataFrame) -> list:
    d = d.dropna()
    d_count = d['name'].value_counts(sort=False)
    d_count_count = d_count.value_counts()
    d_dim = [d_count_count.index[0], d_count_count.array[0]]
    print('Data standard will be: ')
    print('Stocks with', d_dim[0], 'price entries, since they are the most '
                                   'common type in the input data. ')
    print('There are', d_dim[1], 'stocks fitting this criteria. ')
    accepted_data_names = d_count[d_count == d_dim[0]]
    d = d[d['name'].isin(accepted_data_names.index)]
    return [d, d_dim]


# Add a column in DataFrame d called 'mid'.
# 'mid' is an average of high and low price.
def add_mid_price_from_highlow(d: pd.DataFrame) -> pd.DataFrame:
    d['mid'] = (d['high'] + d['low']) / 2
    return d


# Add a column in DataFrame d called 'mid'.
# 'mid' is an average of open and close price.
def add_mid_price_from_openclose(d: pd.DataFrame) -> pd.DataFrame:
    d['mid'] = (d['open'] + d['close']) / 2
    return d
