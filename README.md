# SCRATCH CAR！ 🎁🚗

**くるまのラッピングを指でこすって開けよう！ボタンを押してあそぼう！**

小さな子供から大人まで楽しめる、GitHub Pages で動く Flutter 製インタラクティブゲームです。

---

## 🎮 遊び方

### Phase 1: スクラッチ！
- 画面に包み紙に包まれた車が現れる
- 指（またはマウス）でゴシゴシこすると車が現れる
- 68% 以上こすると紙吹雪と共にご開帳！

### Phase 2: あそぼう！
車が現れたら、まわりのボタンを押して遊べる：

| ボタン | 効果 |
|--------|------|
| 📯 プップー | ホーンを鳴らす |
| 💡 ライト | ヘッドライトが点滅 |
| 🚿 せんしゃ | 水しぶきが降る |
| 🎉 パーティ | 紙吹雪が舞う |
| 🌀 くるくる | 車がスピン |
| 🌈 いろかえ | 車の色が変わる |

「**もういっかい！**」で新しい色の車が登場。毎回違う色・柄で何度でも楽しめる。

---

## 🚀 GitHub Pages へのデプロイ

```bash
# ビルド（リポジトリ名を base-href に）
flutter build web --release --base-href /scratch-car-interior/

# docs/ フォルダを更新
rm -rf docs && cp -r build/web docs

# コミット & プッシュ
git add docs lib web pubspec.yaml README.md
git commit -m "feat: SCRATCH CAR！ Flutter game"
git push
```

GitHub リポジトリ Settings → Pages → main / docs → Save で公開完了。

---

## 🛠 ローカル開発

```bash
flutter pub get
flutter run -d chrome
```

---

## 技術の見どころ

| 技術 | 用途 |
|------|------|
| `Canvas` + **`BlendMode.dstOut`** | スクラッチカード削り効果（saveLayer 内でリアルタイムマスク） |
| **`FragmentShader`** 相当の `LinearGradient` | ギフトラッピングのシマー表現 |
| `GestureDetector.onPanUpdate` | 60fps スムーズな指の軌跡追跡 |
| `CustomPainter` + 独自車デザイン | 完全オリジナルちびカー（実在ブランドなし） |
| `AnimationController` × 多数 | バウンス・スピン・ライト点滅など多彩なアニメ |
| Web Audio API (`dart:js_interop`) | サウンド全数式生成（音声ファイル 0 本） |
| Particle System | 紙吹雪・スパークル |

**外部パッケージ依存ゼロ**・**著作権フリー完全オリジナル**。

---

## ライセンス

MIT
