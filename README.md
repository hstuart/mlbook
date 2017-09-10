MLBook is a command line tool for building books in a manner that is compatible
with [Gitbook](https://github.com/GitbookIO/gitbook) without share plugin, but
with search plugin.

In order to use it you need a recent ocaml compiler environment and to run the
following commands:

```
make scripts
make build
```

Then you can run it much like `gitbook`:

```
mlbook.native build <book> <destination>
```

It only supports the bare minimum that I've needed and will likely break with
anything moderately complicated.