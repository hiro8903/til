# [Ruby] [Fw] Rails: 多対多の開発手法と `has_many :through` の魔法 (-concept)

「1人の学生が複数の授業を履修し、1つの授業にも複数の学生が参加する」というような、複雑に絡み合うデータの関係性を表現する手法を**「多対多（Many-to-Many）の関連付け」**と呼ぶ。
Railsにおいて多対多を実現する場合は、**必ず意味のある第三のテーブル（中間テーブル）を作成し、`has_many :through` を使うのが絶対的なベストプラクティス**である。

---

## 🚫 過去の学び：絶対に非推奨な方法 (`has_and_belongs_to_many`)

Railsには古くから `has_and_belongs_to_many` (通称: HABTM) という多対多を作るためのコマンドが存在する。
これは「モデル名すら持たない、ただID同士を繋ぐだけの隠し中間テーブルを勝手に作る」機能である。

**【なぜ使ってはいけないのか？】**
最初は楽だが、後から「この人はいつこの部署に入ったの？」「この人はこの部署では課長？それとも平社員？」といった**「関係性そのものに対する追加情報」を持たせることが一切できない**ため、システムの拡張性が完全に死んでしまう。現在のプロの現場ではアンチパターンとして使用が禁じられている。

---

## 💎 推奨される方法: `has_many :through` の仕組み

分かりやすいユースケースとして、**「学生（Student）」と「授業（Course）」**の関係を考える。
- 1人の学生は、複数の授業を取る。
- 1つの授業には、複数の学生がいる。
- 単に紐づくだけでなく、その学生の**「成績（grade）」**という情報を絶対に繋がりの上に持たせたい。

### 1. 「意味のある」中間テーブルを作る
ただ双方向を繋ぐ隠しテーブルを作るのではなく、「その繋がりに名前を付ける」ことが最重要。
今回なら、学生と授業を繋ぐために、**履修登録（`Enrollment`）** という独立したモデルとテーブルを作る。

```ruby
# db/migrate/XXXX_create_enrollments.rb
create_table :enrollments do |t|
  t.references :student, null: false, foreign_key: true # 誰が
  t.references :course, null: false, foreign_key: true  # どの授業を
  t.string :grade                                       # 「どんな成績（A, B..）」で履修しているか
end
```
※このように `grade`（成績）のような**独自の追加情報を持たせられること**が、古い `HABTM` 手法との決定的な違いである。

### 2. モデルに魔法のキーワードを書く
両端のモデルから、互いの向こう側が直接見えるようにする「スルー（貫通）」の魔法をかける。

```ruby
# app/models/student.rb (学生)
class Student < ApplicationRecord
  # まず、自分の真横にある中間テーブル（履修登録）と1対多で繋ぐ
  has_many :enrollments, dependent: :destroy
  
  # 次に、中間の「履修登録」をスルー（貫通）して、向こう側の「授業」と直接繋がる魔法！
  has_many :courses, through: :enrollments
end
```

```ruby
# app/models/course.rb (授業)
class Course < ApplicationRecord
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
end
```

---

## 🚀 `through` による絶大なメリット（使い方）

この `through`（スルー）設定さえ書いておけば、Rubyのコードではまるで中間の存在など無いかのように**向こう側のデータを一発リストで取得**できるようになる。

```ruby
# IDが1番の学生が受けている「全ての授業名」を出力する
sato = Student.find(1)

# through が無い世界だと...（中間テーブルをイチイチ経由してループする地獄）
sato.enrollments.each do |enrollment|
  puts enrollment.course.title
end

# ⭐ through の魔法があれば！（直接リストとして手に入る）
sato.courses.each do |course|
  puts course.title
end
```

### この概念と「自己参照」の組み合わせによる無双
この `has_many :through` に、前章で学んだ「自己参照（Self-Referencing）」を合わせることもできる。
例えば「社員同士の『フォロー・フォロワー機能』を作りたい」となった場合、「Followerships」という中間テーブル（誰が誰をいつフォローしたか）を作り、右も左も User を向くというスルー設定を書くことで、いとも簡単にX(旧Twitter)のようなSNSのコア関係性を作り出すことができる。
