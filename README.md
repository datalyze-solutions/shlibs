# shlibs
Useful shell functions for shared usage, e.g. in docker entrypoints 

## Install

```bash
cd /opt/
sudo git clone https://github.com/datalyze-solutions/shlibs
sudo ln -s /opt/shlibs /usr/local/bin
```

## Usage

Simply import `index.sh` to import all shlibs functions.

```bash
source /usr/local/bin/shlibs/index.sh
```

## Development

If you change shlibs functions, you need to import index.sh with the `--reload` flag. This will deregister the functions before resourcing them.

```bash
source /usr/local/bin/shlibs/index.sh --reload
```