# PRコンフリクト解消：`rebase --onto` を使った履歴整理ワークフロー

🔗 **公式ドキュメント一覧**:
*   [Git 公式リファレンス: git-fetch](https://git-scm.com/docs/git-fetch)
*   [Git 公式リファレンス: git-rebase（`--onto` オプション）](https://git-scm.com/docs/git-rebase#Documentation/git-rebase.txt---ontoltnewbasegt)
*   [Git 公式リファレンス: git-stash](https://git-scm.com/docs/git-stash)
*   [GitHub Docs: プルリクエストのマージコンフリクトを解決する](https://docs.github.com/ja/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line)

## 📖 概要

GitHub 上で PR がコンフリクトを起こした場合に、ローカルで `rebase --onto` を使って履歴をクリーンに整理し、コンフリクトを解消する手順をまとめました。
特に、**同じブランチから複数の PR を出した結果、スカッシュマージとの重複でコンフリクトが起きた**ケースに焦点を当てています。

> [!WARNING]
> **同じブランチから複数の PR を出すのは避けるべきパターンです。**
> スカッシュマージとの相性が悪く、このドキュメントで扱うようなコンフリクトの原因になります。推奨パターンは「1 PR = 1 ブランチ（`main` から切る）」です。詳しくは [5. よくある疑問 > Q. そもそもこの状況を防ぐには？](#q-そもそもこの状況を防ぐには) を参照してください。

---

## 🗺️ 1. このドキュメントで扱うシチュエーション

### 前提
- `feature/my-work` ブランチから PR-A を出した
- PR-A が **スカッシュマージ**（複数コミットを1つにまとめてマージ）で `main` に入った
- その後、**同じブランチで作業を続けて** PR-B を出した
- PR-B が GitHub 上で「コンフリクトあり」と表示されている

### なぜコンフリクトが起きるのか
**同じ変更が「2つの形」で存在している**ため：
- `main` には、スカッシュマージで**1つにまとめられた**コミット（`sq1111`）として入っている
- `feature/my-work` には、**元の個別コミット**（`lo1111` 〜 `lo5555`）がそのまま残っている

Git は「中身が同じでもコミットのハッシュが違えば別の変更」と判断するので、コンフリクトが起きる。

```
main:     base1111 → sq1111 (PR-Aのスカッシュマージ = lo1111〜lo5555を1つにまとめたもの)

feature:  base1111 → lo1111 → lo2222 → ... → lo5555 → lo6666 → lo7777 → lo8888
                      ├── PR-Aに含まれていた(5個) ──┤  ├── PR-Bの追加分(3個) ──┤
```

---

## 🧠 2. 知っておくべき概念

### Git の「3つの場所」

`git fetch` と `git pull` の違いを理解するには、Git がデータを保持する3つの場所を知る必要がある。

```
┌───────────────────┐                ┌───────────────────────┐                ┌──────────────────┐
│  リモート (GitHub) │   git fetch    │  リモート追跡ブランチ    │   git merge     │  ローカルブランチ   │
│  origin/main      │  ───────────→  │  origin/main (ローカル) │  ───────────→   │  main             │
│  (GitHubのサーバー) │   情報を取得    │  (.git/内に保存)       │   実際に反映     │  (作業ファイル)     │
└───────────────────┘                └───────────────────────┘                └──────────────────┘
```

### ❓ Q. `git fetch` はどのブランチで打てばいいのか？

**どのブランチにいても結果は同じ。** `git fetch origin` は「リモートの全ブランチの最新情報を `.git/` 内のリモート追跡ブランチにダウンロードする」だけの操作。ローカルのブランチや作業中のファイルには一切影響しない。

| コマンド | ブランチの場所は重要？ | 理由 |
|:---|:---|:---|
| `git fetch origin` | ❌ どこでもOK | リモート追跡のデータ更新だけ |
| `git pull origin main` | ⚠️ 重要 | **今いるブランチ**に main の変更をマージするため |

### ❓ Q. `git log` に表示される `(origin/main)`、`(main)`、ラベルなし の違いは？

```
sq1111 (origin/main)   ← リモート追跡ブランチの先頭（GitHubのmainの最新）
base1111 (main)        ← ローカルのmainブランチの先頭（PC上のmain）
aaa1111                ← どのブランチの先頭でもない（過去の通過点）
```

これらは**「どのブランチの先頭（最新コミット）がここを指しているか」**を示すラベル。GitHub 上にはローカルブランチの情報は存在しないので、`(main)` は純粋に自分の PC 内だけの情報。

### ❓ Q. 未コミットの変更はブランチに属しているのか？

**属していない。** 未コミットの変更は「ワーキングツリー（作業ディレクトリ）」に浮いている状態で、ブランチを切り替えると**一緒についてくる**。「ブランチに置いていく」ことはできない。

```
feature-A にいる時:  未コミット変更が見える
      ↓ git checkout feature-B
feature-B に移動:    未コミット変更がついてくる！（荷物を持ったまま部屋を移動するイメージ）
```

そのため、rebase など作業ディレクトリをクリーンにする必要がある操作の前には `git stash` で一時退避する。

---

## 🔧 3. コンフリクト解消の手順

### 前提の状態
```
main:     base1111 → sq1111 (origin/main)

feature:  base1111 → lo1111 → ... → lo5555 → lo6666 → lo7777 → lo8888 (HEAD)
                                       ↑                          ↑
                                  PR-Aの最後のコミット       PR-Bの最後のコミット
```

### Step 1: 未コミット変更を退避する

```bash
git stash -u -m "作業中の変更を退避"
```
- `-u`: 新規ファイル（Untracked）も含めて退避する
- 退避後、`git stash list` で確認できる
- 後で `git stash pop` で取り出す

### Step 2: リモートの最新情報を取得する

```bash
git fetch origin
```
- リモートの情報を取得するだけ。ローカルファイルは変わらない。

### Step 3: コンフリクトが起きている PR のブランチに移動する

```bash
git checkout feature/my-work
```

### Step 4: `rebase --onto` で必要なコミットだけを載せ替える

```bash
git rebase --onto origin/main lo5555 feature/my-work
```

このコマンドの意味：
```
git rebase --onto <新しい土台> <ここより後だけ対象> <対象ブランチ>
                   origin/main    lo5555(PR-Aの最後)   feature/my-work
```

> [!IMPORTANT]
> **なぜ通常の `git rebase origin/main` ではダメなのか？**
> 通常の rebase は PR-A の古いコミットも1つずつ適用しようとするが、main にはスカッシュ版（ハッシュの違う同じ内容）が入っているため、コミットごとにコンフリクトが発生し、何度も `--skip` する羽目になる。`--onto` なら「ここより後のコミットだけ」を指定できるので、一発で解決する。

#### 結果
```
【Before】
feature:  base1111 → lo1111 → ... → lo5555 → lo6666 → lo7777 → lo8888

【After】
feature:  base1111 → sq1111 (origin/main) → new6666 → new7777 → new8888
                                             ↑ PR-Bの追加分だけが載った（ハッシュは新しくなる）
```

### Step 5: GitHub に反映する（強制プッシュ）

```bash
git push --force-with-lease origin feature/my-work
```

- rebase で履歴を書き換えたため、通常の `push` は拒否される
- `--force-with-lease` は「自分が最後に知っていた状態から変えられていなければ上書きする」安全な強制プッシュ

> [!WARNING]
> `--force`（無条件の強制上書き）ではなく、必ず `--force-with-lease`（安全な強制上書き）を使うこと。他人がプッシュした変更を意図せず消すリスクを防ぐため。

### Step 6: 作業ブランチに戻って stash を復元する

```bash
git checkout feature/next-work
git stash pop
```

---

## 🔄 4. rebase 中にコンフリクトが起きた場合の選択肢

rebase の途中でコンフリクトが発生して止まった場合、3つの選択肢がある：

| 選択肢 | コマンド | 使いどころ |
|:---|:---|:---|
| **解消する** | ファイルを手動修正 → `git add` → `git rebase --continue` | コンフリクト箇所を丁寧に直したい時 |
| **スキップ** | `git rebase --skip` | そのコミットがすでに main に入っている場合 |
| **中止する** | `git rebase --abort` | rebase 前の状態に完全に戻したい時 |

> [!TIP]
> `git rebase --abort` はいつでも使える「安全弁」。rebase を始める前の状態に完全に戻るので、失敗を恐れずに試すことができる。

---

## ❓ 5. よくある疑問

### Q. そもそもこの状況を防ぐには？

**「1 PR = 1 ブランチ（`main` から切る）」が最も安全で一般的なパターン。** 同じブランチから複数の PR を出すのは、以下の理由で避けるべきアンチパターンとされている。

| 問題 | 説明 |
|:---|:---|
| スカッシュマージとの相性が悪い | PR-A がスカッシュマージされるとハッシュが変わり、ブランチ上の元コミットと食い違いが起きる |
| 依存関係が複雑になる | PR-B は PR-A のマージ後でないとレビューしにくく、順序制約が生まれる |
| 履歴整理のコストが高い | `rebase --onto` のような高度な操作が毎回必要になる |

**推奨パターン：**

| やり方 | 推奨度 | 説明 |
|:---|:---|:---|
| **1 PR = 1 ブランチ（`main` から切る）** | ✅ 最も一般的 | 各 PR が独立してレビュー・マージできる |
| **スタック型 PR（ブランチを数珠つなぎ）** | ⚠️ 上級者向け | `feature-a` → `feature-b` と親ブランチを変えて順に PR を出す |
| **同じブランチから複数 PR** | ❌ 非推奨 | このドキュメントで扱うトラブルの元 |

とはいえ、実際にはレビュー待ち中に同じファイルで作業を続けてしまったり、ブランチの切り分けを忘れたりして意図せず起きることがある。そのための解消手順がこのドキュメントの本題。

### Q. PR を出す前にコンフリクトを防ぐことはできる？

**ベストプラクティスは、PR 作成前に main の最新を取り込んでおくこと。**

```bash
git fetch origin
git rebase origin/main   # または git merge origin/main
# コンフリクトがあればローカルで先に解消
git push
# その後に PR を作成
```

ただし、PR 作成後に main 側が更新されてコンフリクトが発生するのは日常的なこと。解消手順を覚えておけば問題ない。

### Q. ローカルブランチは PR がマージされるまで消してはいけない？

**消しても問題ない。** リモートにプッシュ済みであれば、いつでも復元できる。

```bash
# ローカルブランチを消していた場合の復元手順
git fetch origin
git checkout feature/my-work
# → 自動的に origin/feature/my-work を追跡するローカルブランチが作成される
```

ただし、**レビュー待ちなど修正が入る可能性がある間は残しておくのが無難**。

### Q. PR マージ後のブランチ削除は？

**GitHub 上・ローカルともに削除してOK。** PR のページはブランチ削除後もそのまま残る。

```bash
# ローカルの削除
git branch -d feature/my-work

# リモート追跡の参照も整理
git fetch --prune
```

---

## 📋 まとめ：黄金手順チートシート

```bash
# 1. 未コミット変更を退避
git stash -u -m "作業中の退避"

# 2. リモートの最新情報を取得
git fetch origin

# 3. 対象ブランチに移動
git checkout feature/my-work

# 4. PR-Aの最後のコミットより後だけを origin/main の上に載せる
git rebase --onto origin/main <PR-Aの最後のコミットハッシュ> feature/my-work

# 5. GitHub に反映
git push --force-with-lease origin feature/my-work

# 6. 作業ブランチに戻って復元
git checkout feature/next-work
git stash pop
```
