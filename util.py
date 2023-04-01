import pandas as pd


def f2d(f: str) -> dict:
    df = pd.read_csv(f, delimiter=' ', dtype='int64', header=None)
    df.index += 1
    df = df.transpose()
    d = df.to_dict(orient='list')
    return d
