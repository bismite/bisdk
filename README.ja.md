[![Build Status](https://travis-ci.org/bismite/bismite-sdk.svg?branch=master)](https://travis-ci.org/bismite/bismite-sdk)

[English](README.md) | [日本語](README.ja.md)

# Bismite SDK

Bismite SDKは、2Dグラフィックスやサウンドを制御するためのマルチプラットフォーム開発環境です。

macOS、Linux、Windows、Webブラウザ上で動作します。
Webブラウザで動作させるには、WebGLとWebAssemblyのサポートが必要です。

スクリーンショットとライブデモ : https://bismite.github.io/

## インストール

例えば：アーカイブを `$HOME/.bismite` に解凍し、PATH 環境変数を `$HOME/.bismite/bin` に設定します。

## 使用方法

- `birun source.rb` : プログラムを実行します
- `bipackassets path/to/assets path/to/output SECRET` : アセットのディレクトリをアーカイブします
- `biunpackassets assets.dat SECRET` : アーカイブされたアセットを展開します
- `biexport <target> source.rb assets.dat path/to/output` : 対象プラットフォーム向けにエクスポートします
  - `macos`, `linux`, `windows`, `wasm`, `wasm-dl`, `js` から対象を選択できます。

## 開発

Linux あるいは macOS でのビルドが可能です。
ブラウザ向けのビルドには [emscripten](https://emscripten.org/). が必要です。
Windows向けのビルドには [mingw-w64](http://mingw-w64.org/doku.php) が必要です。

`./scripts/setup.sh` コマンドでビルドを開始します。
ビルド対象は、`macos`, `linux`, `mingw`, `emscripten` を選択することができます。
これらのターゲットは1つ以上指定することができ、利用できないターゲットは単純に無視されます。
`all` を指定すると、利用可能な全てのターゲットのビルドを開始します。
引数を指定しない場合は、ホストシステムのみが対象となります。

### Linuxでの開発

`setup.sh` にはruby、SDL2、GLEW、bisonなどが必要です。
これらのパッケージは、以下のコマンドによってインストールできます。（Ubuntu 20.04の場合）

```
sudo apt-get install clang libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libglew-dev ruby bison git curl
```

# ライセンス

Copyright 2018-2020 kbys <work4kbys@gmail.com>

Apache License Version 2.0
