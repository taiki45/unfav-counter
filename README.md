# Unfav checker
いつもの日常… [@enkunkun](https://twitter.com/enkunkun) はあんふぁぼを監視して通知していました。

ところがある日[こんな要望がきたのです](https://twitter.com/tenzingumo/status/307954741231636480)。
```
えんくんのあんふぁぼ通知にカウンターつけて
```

前々からあんふぁぼ通知に興味をもっていたたい氏は練習がてら書いてみることにしました。

## Setup
```sh
git clone git://github.com/taiki45/unfav-counter.git
cd unfav-counter
cp sample.yaml config.yaml
edit config.yaml
gem i bundler # only if you didin't install
bundle
```

## Usage
```sh
bundle exec ruby unfav.rb
```
