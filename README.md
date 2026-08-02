# stphung/homebrew-tap

Homebrew formulae for my file-management tools.

```sh
brew install stphung/tap/ferry
```

## Formulae

| Formula | What it does |
|---|---|
| [`ferry`](https://github.com/stphung/ferry) | Guarded two-way mirror between a NAS folder and OneDrive. Wraps `rclone bisync` in the safety rails a mirror of real data needs. |
| [`salvage`](https://github.com/stphung/salvage) | *If I delete this, what do I lose?* Compares a directory against backups by content, and lists what exists nowhere else. |

Each formula declares its own runtime dependencies, so a fresh Mac needs one
command per tool — `rclone` for `ferry`, `rmlint` and `jq` for `salvage`, all
pulled in automatically.

## Updating a formula after a release

The formulae point at GitHub's auto-generated tag tarballs, so no release
assets are required — pushing a tag is enough. To bump one:

```sh
tag=v0.2.0
tool=ferry
url="https://github.com/stphung/$tool/archive/refs/tags/$tag.tar.gz"
curl -fsSL "$url" | shasum -a 256
```

Then update `url` and `sha256` in `Formula/$tool.rb` and commit.

## Testing a change locally

```sh
brew install --build-from-source ./Formula/ferry.rb
brew test ferry
brew audit --strict --formula ./Formula/ferry.rb
```
