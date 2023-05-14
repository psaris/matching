import pandas as pd
import numpy as np


def f2d(f: str) -> dict:
    """read f as csv and return dict of int64 np.ndarrays"""
    df = pd.read_csv(f, delimiter=' ', dtype='int64', header=None)
    df.index += 1
    df = df.transpose()
    d = df.to_dict(orient='list')
    return d


def l2a(d: dict) -> dict:
    """convert dictionary of lists to dictionary of np.ndarrays"""
    d = {k: np.array(v) for (k, v) in d.items()}
    return d
