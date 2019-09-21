# fish-conda

NOTE: package no longer necessary and has been archived.  Run `conda init fish` to append appropriate scripts to `config.fish`.

Package implementing [conda](https://docs.conda.io/en/latest/) support for the [fish shell](https://fishshell.com) :fish:.


## Installing

Using [`fisher`](https://github.com/jorgebucaran/fisher):

```fish
fisher add lewisacidic/fish-conda
```

If you have installed conda into your home dir, this is all that is needed.
However, if `conda` is installed somewhere else, set the environment variable `CONDA_ROOT` to its location:

```fish
set -U CONDA_ENV {path to anaconda/miniconda install}
```

The location is usually a directory called miniconda3? or anaconda3?.


## Usage

The package adds the `conda` command to the path, and can be used as advertised in their docs, e.g.

```fish
conda create -n test python=3
conda install numpy
conda list
```

