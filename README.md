# dotfiles

Just my dotfiles.

## Setup instructions

``` shell
git clone --recurse-submodules https://github.com/svraka/dotfiles.git ~/.dotfiles
pushd ~/.dotfiles
./install
popd
```

## Conda environments

To be precise, [mamba](https://mamba.readthedocs.io/en/latest/index.html) environments, which is a "*drop-in* replacement for conda, offering higher speed and more reliable environment solutions". Python tools are managed as conda/mamba environments, install them using

```
find config/conda/environments -type f | xargs -I '{}' mamba env create --file {}
```

These are intended to be used as the main installations for these tools, called using shims from anywhere (see under [local/bin](local/bin)) but of course activating conda environments works too.

Check for updates like this:

```
mamba update --name snakemake --dry-run snakemake
```
