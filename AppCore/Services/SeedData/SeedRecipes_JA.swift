import Foundation

extension SeedData {
    static let japaneseRecipes: [Recipe] = [
        Recipe(
            id: UUID(uuidString: "BF150F53-89A1-4087-8EA1-0A13A0A0792C")!,
            title: "スパイシー・タイ風ビーフラープ",
            description: "豊かな風味と食感が詰まったタイ風サラダ。炒った米を砕いて加えることで、香ばしさとソースの絡みが格段にアップします。",
            imageURLs: [.bundled(name: "seed-spicy-thai-beef-larb")],
            ingredientsInfo: Ingredients(
                servings: nil,
                sections: [IngredientSection(items: [
                    Ingredient(name: "ジャスミンライス（生）", amount: "1/4カップ"),
                    Ingredient(name: "ピーナッツ", amount: "1/4カップ"),
                    Ingredient(name: "ココナッツオイル", amount: "大さじ1"),
                    Ingredient(name: "牛ひき肉", amount: "1ポンド"),
                    Ingredient(name: "塩", amount: "小さじ1/2"),
                    Ingredient(name: "粗挽き黒こしょう", amount: "小さじ1/4"),
                    Ingredient(name: "レッドペッパーフレーク", amount: "小さじ1/2"),
                    Ingredient(name: "にんにく（みじん切り）", amount: "4片"),
                    Ingredient(name: "赤唐辛子（薄切り）", amount: "2本"),
                    Ingredient(name: "ライム（皮と果汁）", amount: "3個"),
                    Ingredient(name: "醤油", amount: "大さじ1"),
                    Ingredient(name: "エシャロット（薄切り）", amount: "2個"),
                    Ingredient(name: "青ねぎ（薄切り）", amount: "2本"),
                    Ingredient(name: "フレッシュパクチー（飾り用に追加も）", amount: "1/4カップ"),
                    Ingredient(name: "フレッシュミント（飾り用に追加も）", amount: "1/4カップ"),
                    Ingredient(name: "ボストンレタス（葉をはがす）", amount: "1個"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "生米を中華鍋またはフライパンに入れ、弱火で頻繁にかき混ぜながら8〜10分、こんがりきつね色になるまで乾煎りする。すり鉢、フードプロセッサー、またはブレンダーで粗く砕いて粉状にし、取り置く。"),
                CookingStep(stepNumber: 2, instruction: "同じフライパンにココナッツオイルを入れ、中強火で熱する。牛ひき肉を加え、木べらでほぐしながら6〜7分、焼き色がつくまで炒める。肉をフライパンの片側に寄せ、空いた側にピーナッツを入れて3〜4分炒る。塩、こしょう、レッドペッパーフレーク、にんにく、赤唐辛子、ライムの皮と果汁、醤油、エシャロット、青ねぎ、パクチー、ミント、炒り米粉を加え、全体をよく混ぜ合わせる。"),
                CookingStep(stepNumber: 3, instruction: "ボストンレタスの葉に盛り付け、熱いうちにいただく。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/08/02/spicy-thai-beef-larb/")
        ),
        Recipe(
            id: UUID(uuidString: "9682B83C-13B0-43FE-A99B-8C67489920D3")!,
            title: "ココナッツスムージーボウル（自家製プラヤボウル）",
            description: "濃厚でクリーミーなココナッツスムージーに新鮮なベリー、グラノーラ、ココナッツフレークをトッピングした、まるでバカンス気分のトロピカル朝食。",
            imageURLs: [.bundled(name: "seed-coconut-smoothie-bowl")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "ココナッツミルク", amount: "3缶"),
                    Ingredient(name: "冷凍バナナ", amount: "½本"),
                    Ingredient(name: "はちみつ", amount: "¼カップ"),
                    Ingredient(name: "オレンジジュース", amount: "¼カップ"),
                    Ingredient(name: "グラノーラ", amount: "1カップ"),
                    Ingredient(name: "はちみつ（トッピング用）", amount: "¼カップ"),
                    Ingredient(name: "いちご（スライス）", amount: "1½カップ"),
                    Ingredient(name: "ブルーベリー", amount: "1½カップ"),
                    Ingredient(name: "ココナッツフレーク", amount: "¼カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "ココナッツミルク2缶分を製氷皿に注ぎ、完全に凍るまで冷凍する。"),
                CookingStep(stepNumber: 2, instruction: "ココナッツミルクの氷、ココナッツミルク1カップ、冷凍バナナ、はちみつ、オレンジジュースをブレンダーに入れる。濃厚で滑らかになるまでブレンドする。混ぜにくい場合はオレンジジュースを少しずつ加える。できるだけ濃厚な仕上がりにすること。"),
                CookingStep(stepNumber: 3, instruction: "ココナッツミクスチャーを4つのボウルに盛り付ける。それぞれにグラノーラ、はちみつ、いちご、ブルーベリー、ココナッツフレークをトッピングする。すぐに召し上がれ。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/07/23/coconut-smoothie-bowl/")
        ),
        Recipe(
            id: UUID(uuidString: "3EFBCECD-22A7-496A-8EB9-960E512C744C")!,
            title: "シャクシュカ",
            description: "スパイス香るトマトソースに卵を落として煮込む北アフリカの定番料理。イスラエルでは朝食の定番として親しまれています。",
            imageURLs: [.bundled(name: "seed-shakshuka")],
            ingredientsInfo: Ingredients(
                servings: "1人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "オリーブオイル", amount: "大さじ2"),
                    Ingredient(name: "大きな玉ねぎ（みじん切り）", amount: "1個"),
                    Ingredient(name: "赤パプリカ（みじん切り）", amount: "½個"),
                    Ingredient(name: "オレンジパプリカ（みじん切り）", amount: "½個"),
                    Ingredient(name: "にんにく（みじん切り）", amount: "3片"),
                    Ingredient(name: "パプリカパウダー", amount: "小さじ1"),
                    Ingredient(name: "キャラウェイシード", amount: "小さじ1"),
                    Ingredient(name: "クミン", amount: "小さじ1"),
                    Ingredient(name: "ターメリック", amount: "小さじ½"),
                    Ingredient(name: "塩", amount: "小さじ½"),
                    Ingredient(name: "こしょう（挽きたて）", amount: "小さじ¼"),
                    Ingredient(name: "ダイストマト缶（28オンス）", amount: "1缶"),
                    Ingredient(name: "トマトペースト", amount: "大さじ2"),
                    Ingredient(name: "ハリッサまたはホットソース（お好みで）", amount: "大さじ2"),
                    Ingredient(name: "はちみつ", amount: "大さじ2"),
                    Ingredient(name: "赤ワインビネガー", amount: "小さじ1"),
                    Ingredient(name: "卵（大）", amount: "5個"),
                    Ingredient(name: "フェタチーズ（角切り）", amount: "½カップ"),
                    Ingredient(name: "パクチー（みじん切り）", amount: "大さじ1"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "大きくて浅いフライパンにオリーブオイルを入れ、中強火で熱します。玉ねぎ、にんにく、赤パプリカ、オレンジパプリカを加え、柔らかくなるまで約5分炒めます。次にパプリカパウダー、キャラウェイシード、クミン、ターメリック、塩、こしょうを加え、絶えずかき混ぜながらさらに1分炒めます。"),
                CookingStep(stepNumber: 2, instruction: "トマト、トマトペースト、ハリッサ、はちみつ、赤ワインビネガーを加えます。火を中火に落とし、10分煮込みます。ソースはある程度とろみがつきつつも、パンを揺するとまだ流れる程度が目安です。スプーンの背でソースに5つのくぼみを作り、それぞれに卵を1つずつ割り入れます。蓋をして、卵がお好みの固さになるまで加熱を続けます。火からおろし、フェタチーズとパクチーをのせます。温かいピタパンと一緒にお召し上がりください。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/07/02/shakshuka/")
        ),
        Recipe(
            id: UUID(uuidString: "34DD05D2-BBB7-448A-83F9-E5EBF0203385")!,
            title: "インポッシブル チョリソーナチョス",
            description: "とろけるチーズ、ワカモレ、サルサ、サワークリーム、そしてインポッシブルバーガーで作るスパイシーなチョリソーそぼろをたっぷりのせたナチョス。",
            imageURLs: [.bundled(name: "seed-impossible-chorizo-nachos")],
            ingredientsInfo: Ingredients(
                servings: "1人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "植物油", amount: "大さじ1"),
                    Ingredient(name: "玉ねぎ（みじん切り）", amount: "½個"),
                    Ingredient(name: "にんにく", amount: "2片"),
                    Ingredient(name: "インポッシブルバーガー", amount: "1パック（約340グラム）"),
                    Ingredient(name: "チポトレ・イン・アドボ（種を取り刻む）", amount: "1個"),
                    Ingredient(name: "アドボソース", amount: "大さじ1"),
                    Ingredient(name: "水", amount: "120ミリリットル"),
                    Ingredient(name: "チリパウダー", amount: "大さじ½"),
                    Ingredient(name: "クミン", amount: "小さじ1"),
                    Ingredient(name: "パプリカパウダー", amount: "小さじ1"),
                    Ingredient(name: "オレガノ", amount: "小さじ½"),
                    Ingredient(name: "コーシャーソルト", amount: "小さじ½"),
                    Ingredient(name: "粗挽き黒こしょう", amount: "小さじ¼"),
                    Ingredient(name: "完熟アボカド", amount: "4個"),
                    Ingredient(name: "ライム果汁", amount: "1個分"),
                    Ingredient(name: "レモン果汁", amount: "½個分"),
                    Ingredient(name: "小玉ねぎ（みじん切り）", amount: "1個"),
                    Ingredient(name: "にんにく（みじん切り）", amount: "1片"),
                    Ingredient(name: "ハラペーニョ（みじん切り）", amount: "小さじ1"),
                    Ingredient(name: "パクチー（刻む）", amount: "大さじ1"),
                    Ingredient(name: "コーシャーソルト", amount: "小さじ½"),
                    Ingredient(name: "粗挽き黒こしょう", amount: "小さじ¼"),
                    Ingredient(name: "トルティーヤチップス", amount: "1袋"),
                    Ingredient(name: "チェダーチーズ（シュレッド）", amount: "240ミリリットル"),
                    Ingredient(name: "モントレージャックチーズ（シュレッド）", amount: "240ミリリットル"),
                    Ingredient(name: "サワークリーム", amount: "120ミリリットル"),
                    Ingredient(name: "ピクルスハラペーニョ（スライス）", amount: "60ミリリットル"),
                    Ingredient(name: "ピコ・デ・ガヨ", amount: "240ミリリットル"),
                    Ingredient(name: "パクチー（刻む）", amount: "大さじ2"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "フライパンに植物油を入れ中火で熱し、刻んだ玉ねぎとにんにくを3〜4分、透き通るまで炒める。"),
                CookingStep(stepNumber: 2, instruction: "インポッシブルバーガーを加え、崩しながら4〜5分、きつね色になるまで炒める。"),
                CookingStep(stepNumber: 3, instruction: "チポトレ、アドボソース、水、チリパウダー、クミン、パプリカパウダー、オレガノ、塩、こしょうを加えてよく混ぜる。5分ほど煮詰めて水分を飛ばし、盛り付けまで弱火で保温する。"),
                CookingStep(stepNumber: 4, instruction: "ワカモレを作る：大きめのボウルでアボカドをつぶし、ライム果汁、レモン果汁、みじん切りの玉ねぎ、にんにく、ハラペーニョ、パクチーを混ぜ合わせる。塩とこしょうで味を調え、ラップで密封して使うまで置く。"),
                CookingStep(stepNumber: 5, instruction: "オーブンをブロイル（上火強）に予熱する。天板にトルティーヤチップスを広げ、チェダーチーズとモントレージャックチーズの半量、チョリソーミックス、残りのチーズの順にのせる。"),
                CookingStep(stepNumber: 6, instruction: "ブロイルで3〜4分、チーズが溶けて泡立つまで焼く。"),
                CookingStep(stepNumber: 7, instruction: "ワカモレ、サワークリーム、ピクルスハラペーニョ、ピコ・デ・ガヨ、パクチーをトッピングし、すぐに食卓に出す。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/01/27/impossible-chorizo-nachos/")
        ),
        Recipe(
            id: UUID(uuidString: "27CE6371-C411-4E56-9570-2849D8967E11")!,
            title: "簡単チョコチップパンケーキ",
            description: "チョコチップたっぷりのふわふわ自家製パンケーキ。短時間で作れる週末の朝食にぴったりの一品。",
            imageURLs: [.bundled(name: "seed-chocolate-chip-pancakes")],
            ingredientsInfo: Ingredients(
                servings: "1人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "薄力粉", amount: "2カップ"),
                    Ingredient(name: "ベーキングパウダー", amount: "大さじ1"),
                    Ingredient(name: "塩", amount: "小さじ1/2"),
                    Ingredient(name: "砂糖（お好みで）", amount: "大さじ1"),
                    Ingredient(name: "チョコチップ", amount: "1/2カップ"),
                    Ingredient(name: "卵", amount: "2個"),
                    Ingredient(name: "牛乳", amount: "1と1/2カップ"),
                    Ingredient(name: "溶かしバター（焼く用に追加分も）", amount: "大さじ3"),
                    Ingredient(name: "ホイップクリーム（お好みで）", amount: nil),
                    Ingredient(name: "メープルシロップ（お好みで）", amount: nil),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "大きなボウルに薄力粉、ベーキングパウダー、塩、砂糖、チョコチップを入れて混ぜる。小さなボウルで卵、牛乳、溶かしバターを混ぜ合わせる。湿った材料を乾いた材料に注ぎ、泡立て器でしっかり混ぜ合わせる。"),
                CookingStep(stepNumber: 2, instruction: "バターを塗った鉄板またはフライパンを中火で熱する。生地を約1/4カップずつ流し入れる。表面に気泡が現れ、端が乾き始め、底がきつね色になるまで約3分焼く。"),
                CookingStep(stepNumber: 3, instruction: "パンケーキをひっくり返す。裏面もきつね色になるまで2〜3分焼く。皿に移し、残りの生地も同様に焼く。"),
                CookingStep(stepNumber: 4, instruction: "お好みでホイップクリームやメープルシロップをかけて、すぐに召し上がれ。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/01/20/easy-chocolate-chip-pancakes/")
        ),
        Recipe(
            id: UUID(uuidString: "DCBB31A1-52DA-44CB-AB9F-6E5CC9CA101B")!,
            title: "アイリッシュ・コルカノン",
            description: "バターとクリームをたっぷり使ったアイルランドの伝統的なマッシュポテト。フレッシュケールとスキャリオンを混ぜ込み、食感と彩りを加えた一品。",
            imageURLs: [.bundled(name: "seed-irish-colcannon")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "ラセットポテトまたはユーコンゴールドポテト", amount: "約900グラム"),
                    Ingredient(name: "無塩バター", amount: "大さじ4（盛り付け用に追加で適量）"),
                    Ingredient(name: "生クリーム", amount: "120ミリリットル"),
                    Ingredient(name: "牛乳", amount: "60ミリリットル"),
                    Ingredient(name: "ケール（茎を除き、葉をざく切り）", amount: "4カップ"),
                    Ingredient(name: "スキャリオン（小口切り）", amount: "6本"),
                    Ingredient(name: "コーシャーソルト", amount: "適量"),
                    Ingredient(name: "粗挽き黒こしょう", amount: "適量"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "じゃがいもの皮を剥き、約2.5センチ角に切る。大きな鍋に入れ、かぶるくらいの冷水と塩ひとつまみを加える。強火で沸騰させた後、中火に落としてフォークがすっと通るまで15〜20分ほど茹でる。"),
                CookingStep(stepNumber: 2, instruction: "じゃがいもを茹でている間に、フライパンにバター大さじ2を中火で溶かす。刻んだケールを加え、時々混ぜながらしんなりするまで約5分炒める。スキャリオンを加えてさらに1〜2分炒め、火から下ろしておく。"),
                CookingStep(stepNumber: 3, instruction: "小鍋に生クリームと牛乳を入れ、弱火で湯気が立つ程度まで温める。沸騰させないこと。"),
                CookingStep(stepNumber: 4, instruction: "じゃがいもの湯をしっかり切り、鍋に戻す。ポテトマッシャーやライサーで滑らかに潰す。残りのバター大さじ2と温めたクリームを加え、よく混ぜ合わせる。"),
                CookingStep(stepNumber: 5, instruction: "ケールとスキャリオンの炒めたものをマッシュポテトに折り込む。塩とたっぷりの粗挽き黒こしょうで味を調える。"),
                CookingStep(stepNumber: 6, instruction: "器に盛り、中央にくぼみを作ってバターをひとかけのせる。すぐに召し上がれ。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/12/05/colcannon/")
        ),
        Recipe(
            id: UUID(uuidString: "646F7CC0-236A-4EC0-9EE2-0754D133262E")!,
            title: "スイカレモネードスラッシー",
            description: "鮮やかなスイカのスラッシーと自家製レモネードアイスを重ねた、夏にぴったりの爽やかなフローズンドリンク。",
            imageURLs: [.bundled(name: "seed-watermelon-lemonade-slushie")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "レモン汁", amount: "1カップ（レモン約8〜10個分）"),
                    Ingredient(name: "砂糖", amount: "1カップ"),
                    Ingredient(name: "水", amount: "1カップ"),
                    Ingredient(name: "スイカ（角切り）", amount: "4カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "鍋に砂糖と水1カップを入れて中火にかける。沸騰させたら、かき混ぜながら砂糖が溶けるまで煮る。火を止めてレモン汁を加える。"),
                CookingStep(stepNumber: 2, instruction: "混合液を製氷皿またはラップを敷いたパウンド型に注ぐ。6時間以上または一晩冷凍する。"),
                CookingStep(stepNumber: 3, instruction: "角切りスイカをベーキングシートに並べ、6時間以上または一晩冷凍する。"),
                CookingStep(stepNumber: 4, instruction: "凍ったレモネードキューブをハイパワーブレンダーでスラッシー状になるまで撹拌する。密閉容器に移す。"),
                CookingStep(stepNumber: 5, instruction: "凍ったスイカをお好みのスラッシー状になるまでブレンダーで撹拌する。"),
                CookingStep(stepNumber: 6, instruction: "背の高いグラスに層状に盛り付ける。1/3をスイカミックス、2/3をレモネードスラッシーで満たし、上にスイカを追加してすぐに提供する。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/09/01/watermelon-lemonade-slushie/")
        ),
        Recipe(
            id: UUID(uuidString: "C39BE14C-A122-4C93-9943-7C297902DE7D")!,
            title: "モカカップケーキ クッキー&クリームフロスティング",
            description: "濃厚なチョコレートコーヒーカップケーキに、砕いたオレオ入りのふわふわバニラバタークリームフロスティングをトッピング。",
            imageURLs: [.bundled(name: "seed-mocha-cupcakes")],
            ingredientsInfo: Ingredients(
                servings: "24個分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "薄力粉（型用に追加分あり）", amount: "360ミリリットル"),
                    Ingredient(name: "重曹", amount: "小さじ3/4"),
                    Ingredient(name: "インスタントコーヒー顆粒", amount: "60ミリリットル"),
                    Ingredient(name: "細粒海塩", amount: "小さじ1"),
                    Ingredient(name: "卵（Lサイズ・室温）", amount: "2個"),
                    Ingredient(name: "砂糖", amount: "360ミリリットル"),
                    Ingredient(name: "キャノーラ油", amount: "180ミリリットル"),
                    Ingredient(name: "サワークリーム（室温）", amount: "120ミリリットル"),
                    Ingredient(name: "バニラエクストラクト", amount: "大さじ1"),
                    Ingredient(name: "無糖ココアパウダー", amount: "240ミリリットル"),
                    Ingredient(name: "熱いドリップコーヒー", amount: "240ミリリットル"),
                    Ingredient(name: "無塩バター（十分に柔らかくしたもの）", amount: "240ミリリットル"),
                    Ingredient(name: "粉砂糖（お好みで追加可）", amount: "960ミリリットル"),
                    Ingredient(name: "バニラエクストラクト（フロスティング用）", amount: "大さじ1"),
                    Ingredient(name: "生クリームまたは牛乳", amount: "大さじ4"),
                    Ingredient(name: "オレオ（粗く砕く）", amount: "12枚"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "オーブンを180℃に予熱する。12個取りのカップケーキ型2つにバターを塗り、薄力粉をはたく。"),
                CookingStep(stepNumber: 2, instruction: "大きなボウルに薄力粉、重曹、インスタントコーヒー、塩を入れて泡立て器で混ぜ合わせる。"),
                CookingStep(stepNumber: 3, instruction: "別のボウルで卵を30秒〜1分ほど泡立て、砂糖、キャノーラ油、サワークリーム、バニラエクストラクトを加えてよく混ぜ合わせる。"),
                CookingStep(stepNumber: 4, instruction: "さらに別のボウルにココアパウダーを入れ、熱いコーヒーを注いでよく混ぜ合わせる。"),
                CookingStep(stepNumber: 5, instruction: "コーヒーココア液を、卵が固まらないよう絶えず泡立てながら、ゆっくりと卵液に注ぎ入れる。"),
                CookingStep(stepNumber: 6, instruction: "粉類のボウルに液体を注ぎ入れ、大きなゴムベラでさっくりと混ぜ合わせる（混ぜすぎない）。"),
                CookingStep(stepNumber: 7, instruction: "カップケーキ型の2/3程度まで生地を流し入れる。"),
                CookingStep(stepNumber: 8, instruction: "18〜20分焼く。つまようじを刺して少し湿ったクラムが付く程度（生の生地が付かない状態）になったら取り出す。ラックの上で10分冷まし、型から外して完全に冷ます。"),
                CookingStep(stepNumber: 9, instruction: "フロスティング：十分に柔らかくしたバターを中高速で4〜6分、白っぽくふわふわになるまで泡立てる。"),
                CookingStep(stepNumber: 10, instruction: "粉砂糖を1カップずつ加え、最初は低速、その後中高速で混ぜる。4カップ入れたら味見し、お好みでさらに追加する。"),
                CookingStep(stepNumber: 11, instruction: "バニラエクストラクトと生クリームを加え、2〜3分ふわふわになるまで泡立てる。固すぎる場合はクリームを大さじ1ずつ追加する。"),
                CookingStep(stepNumber: 12, instruction: "砕いたオレオを加え、低速でさっくり混ぜ込む。"),
                CookingStep(stepNumber: 13, instruction: "カップケーキ1個につきフロスティングを大さじ2〜3のせる。密閉容器で2日間保存可能。冷凍で最大2ヶ月保存可能。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/09/12/mocha-cupcakes-with-cookies-n-cream-frosting/")
        ),
        Recipe(
            id: UUID(uuidString: "A94CC7B4-6001-4B56-BB5E-2E25889120B4")!,
            title: "マンゴー・ザクロ・ピスタチオスクエア",
            description: "ナッツ香るピスタチオクラスト、クリーミーなマンゴーカード、酸味のあるザクロゼリーの3層デザート。おもてなしに最適で、数時間前に準備可能。",
            imageURLs: [.bundled(name: "seed-mango-pomegranate-pistachio")],
            ingredientsInfo: Ingredients(
                servings: "9人分",
                sections: [
                    IngredientSection(header: "ピスタチオクラスト用", items: [
                        Ingredient(name: "無塩むきピスタチオ", amount: "340グラム"),
                        Ingredient(name: "砂糖", amount: "60ミリリットル"),
                        Ingredient(name: "コーシャソルト", amount: "1.25ミリリットル"),
                        Ingredient(name: "卵", amount: "1個"),
                        Ingredient(name: "溶かしバター", amount: "30ミリリットル"),
                    ]),
                    IngredientSection(header: "マンゴーフィリング用", items: [
                        Ingredient(name: "砂糖", amount: "120ミリリットル"),
                        Ingredient(name: "コーンスターチ", amount: "15ミリリットル"),
                        Ingredient(name: "卵", amount: "3個"),
                        Ingredient(name: "マンゴーピューレ（裏ごし済み）", amount: "240ミリリットル（マンゴー約3個分）"),
                        Ingredient(name: "レモン汁", amount: "60ミリリットル（大きめのレモン約1個分）"),
                    ]),
                    IngredientSection(header: "ザクロゼリー用", items: [
                        Ingredient(name: "ザクロジュース", amount: "240ミリリットル（分けて使用）"),
                        Ingredient(name: "粉ゼラチン", amount: "約7グラム"),
                        Ingredient(name: "砂糖", amount: "15ミリリットル"),
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(header: "ピスタチオクラスト", items: [
                    CookingStep(stepNumber: 1, instruction: "20センチ四方の型にクッキングシートを敷く。取り出しやすいよう四辺にはみ出しを残す。"),
                    CookingStep(stepNumber: 2, instruction: "フードプロセッサーでピスタチオを約30秒細かく砕く。砂糖60ミリリットルと塩を加えてパルスで混ぜ、卵1個と溶かしバターを加えてまとまるまで撹拌する。平らなコップの底を使い、生地を型に均一にしっかり押し付ける。フィリングを準備する間、冷蔵庫で冷やす。"),
                ]),
                CookingStepSection(header: "マンゴーカード", items: [
                    CookingStep(stepNumber: 3, instruction: "オーブンを180℃に予熱する。"),
                    CookingStep(stepNumber: 4, instruction: "ボウルに砂糖120ミリリットル、コーンスターチ、卵3個、マンゴーピューレ、レモン汁を入れ、1〜2分しっかり混ぜ合わせる。冷やしておいたピスタチオクラストの上に流し入れる。"),
                    CookingStep(stepNumber: 5, instruction: "35〜40分焼く。マンゴーフィリングがほぼ固まり、中央がわずかに揺れる程度になればOK。室温まで冷ましてから、冷蔵庫で最低2時間（または一晩）冷やす。"),
                ]),
                CookingStepSection(header: "ザクロゼリー", items: [
                    CookingStep(stepNumber: 6, instruction: "小さなボウルにザクロジュース60ミリリットルを入れ、ゼラチンを表面に均一にふり入れる。ふやかしておく。"),
                    CookingStep(stepNumber: 7, instruction: "小鍋に残りのザクロジュース180ミリリットルと砂糖15ミリリットルを入れ、沸騰させる。ふやかしたゼラチンに注ぎ、完全に溶けるまで混ぜる。液状のまま冷めるまで約20分冷蔵庫で冷やす。"),
                    CookingStep(stepNumber: 8, instruction: "冷えたザクロ液を泡立て器でよく混ぜ、固まりかけたゼラチンをなじませる。マンゴー層の上に均一に流し入れ、冷蔵庫で最低2時間、ゼリーが完全に固まるまで冷やす。"),
                    CookingStep(stepNumber: 9, instruction: "クッキングシートのはみ出し部分を持って型から取り出す。9等分にカットする。冷蔵保存。"),
                ])
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/07/25/mango-pomegranate-pistachio-squares/")
        ),
        Recipe(
            id: UUID(uuidString: "325A6995-3A17-4804-B0C6-86D29E0812EC")!,
            title: "BBQパストラミ・グリルドピザ",
            description: "パストラミとビーフベーコンをキャラメリゼし、ハニーBBQソースを塗ったグリルピザにルッコラを添えた一品。",
            imageURLs: [.bundled(name: "seed-bbq-pastrami-pizza")],
            ingredientsInfo: Ingredients(
                servings: "6人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "ビーフベーコン（2.5センチ幅に切る）", amount: "170グラム"),
                    Ingredient(name: "黄玉ねぎ（薄切り、大½個分）", amount: "1カップ"),
                    Ingredient(name: "パストラミ（スライス、2.5センチ幅に切る）", amount: "230グラム"),
                    Ingredient(name: "ガーリックパウダー", amount: "小さじ½"),
                    Ingredient(name: "スモークパプリカ", amount: "小さじ½"),
                    Ingredient(name: "カイエンペッパー", amount: "小さじ½"),
                    Ingredient(name: "コーシャーソルト・黒こしょう", amount: "適量"),
                    Ingredient(name: "市販のピザ生地", amount: "450グラム"),
                    Ingredient(name: "ハニーバーベキューソース", amount: "80ミリリットル"),
                    Ingredient(name: "ルッコラ", amount: "1カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "大きめのフライパンにビーフベーコンを入れ、中火で時々かき混ぜながら3分ほど炒めて脂を出す。玉ねぎを加えてキャラメル色になるまで5分炒める。パストラミ、ガーリックパウダー、スモークパプリカを加え、塩こしょうで味を調える。"),
                CookingStep(stepNumber: 2, instruction: "時々かき混ぜながらさらに5分炒め、パストラミに軽く焼き色がついたら火を止める。"),
                CookingStep(stepNumber: 3, instruction: "グリルまたはグリルパンを中火で予熱する。生地を約30×20センチの長方形に伸ばす。グリルに油を塗り、生地をのせて片面4分ずつ焼き、きつね色でカリッとさせる。"),
                CookingStep(stepNumber: 4, instruction: "焼いた生地を天板にのせ、縁2.5センチを残してバーベキューソースを均一に塗る。パストラミの具材をのせ、ルッコラを散らす。6等分に切り、すぐに提供する。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/07/18/bbq-pastrami-grilled-pizza/")
        ),
        Recipe(
            id: UUID(uuidString: "CCB4F25F-9A1E-42F2-9C81-CD8680D59D46")!,
            title: "トマトとメロンのパンツァネッラ",
            description: "完熟トマト、フレッシュメロン、トーストしたサワードウを使った彩り豊かなパンサラダ。塩をふったトマトから出る果汁がバルサミコビネグレットのベースになります。",
            imageURLs: [.bundled(name: "seed-tomato-melon-panzanella")],
            ingredientsInfo: Ingredients(
                servings: "6〜8人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "サワードウブール（2.5センチ角に切る）", amount: "1個（約8カップ）"),
                    Ingredient(name: "エアルームトマト（芯を取り2.5センチのくし切り）", amount: "大2個（約3.5カップ）"),
                    Ingredient(name: "コーシャーソルト", amount: "小さじ1/2（＋適量）"),
                    Ingredient(name: "にんにく（すりおろしまたはみじん切り）", amount: "2片（小さじ約1）"),
                    Ingredient(name: "バルサミコ酢", amount: "1/2カップ"),
                    Ingredient(name: "エクストラバージンオリーブオイル", amount: "1/2カップ"),
                    Ingredient(name: "粗挽き黒こしょう", amount: "適量"),
                    Ingredient(name: "メロン（カンタロープまたはハニーデュー、2.5センチ角に切る）", amount: "1カップ"),
                    Ingredient(name: "バジル（大きい葉はちぎる）", amount: "3/4カップ（約15グラム）"),
                    Ingredient(name: "赤たまねぎ（薄切り）", amount: "1/2カップ"),
                    Ingredient(name: "フレッシュモッツァレラ（2.5センチ角に切る）", amount: "1個（約230グラム）"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "オーブンを180℃に予熱する。"),
                CookingStep(stepNumber: 2, instruction: "天板にパンを並べ、15分焼いて乾燥させる（焦がさない）。完全に冷ます。"),
                CookingStep(stepNumber: 3, instruction: "ボウルの上にザルをセットし、トマトを入れて塩小さじ1/2をふり、10分おいて水分を出す。出たトマトの果汁は取っておく。"),
                CookingStep(stepNumber: 4, instruction: "ビネグレットを作る：取っておいたトマトの果汁ににんにくとバルサミコ酢を加えて混ぜ、オリーブオイルを少しずつ加えながら泡立て器でよく混ぜる。塩とこしょうで味を調える。"),
                CookingStep(stepNumber: 5, instruction: "ボウルにトマト、パン、メロン、バジル、赤たまねぎ、モッツァレラを入れ、ビネグレットを加えてやさしく和える。15分以上おいて味をなじませ、時々混ぜる。すぐに盛り付けて提供する。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/07/07/tomato-melon-panzanella/")
        ),
        Recipe(
            id: UUID(uuidString: "2499E2A0-EBEE-4B86-968E-C5AAC9FB7242")!,
            title: "パルメザントリュフフライ ガーリックアイオリ添え",
            description: "二度揚げでカリカリに仕上げたマッチ棒状のフライドポテトに、パルメザンチーズ、バジル、トリュフオイルを絡め、手作りガーリックアイオリを添えた一品。",
            imageURLs: [.bundled(name: "seed-parmesan-truffle-fries")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [
                    IngredientSection(
                        header: "ローストガーリックアイオリの材料",
                        items: [
                            Ingredient(name: "にんにく（大・みじん切り）", amount: "6片"),
                            Ingredient(name: "サラダ油などの中性オイル", amount: "60ミリリットル"),
                            Ingredient(name: "コーシャーソルト", amount: "適量"),
                            Ingredient(name: "卵黄", amount: "2個分"),
                            Ingredient(name: "レモン汁", amount: "ティースプーン2杯"),
                            Ingredient(name: "ウスターソース", amount: "ティースプーン½杯"),
                            Ingredient(name: "ホットソース", amount: "適量"),
                            Ingredient(name: "黒こしょう（挽きたて）", amount: "適量"),
                        ]
                    ),
                    IngredientSection(
                        header: "パルメザントリュフフライの材料",
                        items: [
                            Ingredient(name: "植物油（揚げ油用）", amount: nil),
                            Ingredient(name: "ラセットポテト（洗って約6ミリメートル幅のマッチ棒状に切る）", amount: "4個"),
                            Ingredient(name: "パルメザンチーズ（すりおろし）", amount: "60ミリリットル"),
                            Ingredient(name: "バジル（細切り）", amount: "テーブルスプーン2杯"),
                            Ingredient(name: "黒トリュフオイル", amount: "ティースプーン1杯"),
                            Ingredient(name: "コーシャーソルト", amount: "適量"),
                            Ingredient(name: "黒こしょう（挽きたて）", amount: "適量"),
                        ]
                    ),
                ]
            ),
            stepSections: [
                CookingStepSection(
                    header: "ローストガーリックアイオリの作り方",
                    items: [
                        CookingStep(stepNumber: 1, instruction: "小鍋に中性オイルとみじん切りにしたにんにくを入れ、中弱火で約3分間、にんにくがうっすらきつね色になるまで加熱する。"),
                        CookingStep(stepNumber: 2, instruction: "耐熱計量カップの上に細かい網のザルをセットする。にんにくとオイルをザルに通し、にんにくはボウルに移す。オイルは冷蔵庫で10分以上冷ます。"),
                        CookingStep(stepNumber: 3, instruction: "にんにくの入ったボウルを、タオルを敷いた鍋の上に安定させて置く。卵黄、レモン汁、ウスターソース、ホットソース、こしょうを加える。冷ましたオイルを最初は数滴ずつ、徐々に細い糸状に増やしながら加え、マヨネーズ状に乳化するまで泡立て器でよく混ぜる。固すぎる場合はぬるま湯を少量加えて調整する。"),
                    ]
                ),
                CookingStepSection(
                    header: "パルメザントリュフフライの作り方",
                    items: [
                        CookingStep(stepNumber: 4, instruction: "天板2枚にキッチンペーパーを敷いておく。"),
                        CookingStep(stepNumber: 5, instruction: "深めのフライパンに約4センチメートルの植物油を入れ、175℃に熱する。ポテトを数回に分けて3〜4分、端が色づくまで揚げる。天板に取り出し、バッチの間に油の温度を確認する。"),
                        CookingStep(stepNumber: 6, instruction: "油の温度を200℃に上げる。一度揚げたポテトを再度1〜2分、全体がカリッときつね色になるまで揚げる。きれいなキッチンペーパーに取り出す。"),
                        CookingStep(stepNumber: 7, instruction: "熱々のフライをボウルに入れ、すりおろしたパルメザンチーズ、細切りバジル、黒トリュフオイルを加えてよく絡める。塩とこしょうで味を調え、ガーリックアイオリを添えてすぐに提供する。"),
                    ]
                ),
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/05/09/parmesan-truffle-fries-with-quick-garlic-aioli/")
        ),
        Recipe(
            id: UUID(uuidString: "9DB3BCA1-D26F-40AD-9E26-148009EF81EA")!,
            title: "ラトケス ビーツキュアサーモンロックス添え",
            description: "ハヌカにぴったりの一品。外はカリッと中はふわっとしたポテトラトケスに、自家製ビーツキュアサーモンを合わせます。",
            imageURLs: [.bundled(name: "seed-latkes-beet-cured-salmon")],
            ingredientsInfo: Ingredients(
                servings: nil,
                sections: [
                    IngredientSection(header: "ビーツ漬けサーモン用", items: [
                        Ingredient(name: "皮付きサーモン（中央部分）", amount: "約450グラム"),
                        Ingredient(name: "小さめのビーツ（皮をむいて細かくすりおろす）", amount: "2個"),
                        Ingredient(name: "フレッシュディル（粗く刻む）", amount: "60ミリリットル"),
                        Ingredient(name: "コーシャーソルト", amount: "大さじ3"),
                        Ingredient(name: "砂糖", amount: "大さじ1½"),
                        Ingredient(name: "黒こしょう（挽きたて）", amount: nil),
                    ]),
                    IngredientSection(header: "ラトケス用", items: [
                        Ingredient(name: "サラダ油（植物油またはグレープシードオイル）", amount: nil),
                        Ingredient(name: "ラセットポテト", amount: "約1.1キログラム（中4〜5個）"),
                        Ingredient(name: "玉ねぎ（大）", amount: "1個"),
                        Ingredient(name: "溶き卵", amount: "2個"),
                        Ingredient(name: "薄力粉", amount: "大さじ2"),
                        Ingredient(name: "コーシャーソルト", amount: "適量"),
                        Ingredient(name: "黒こしょう（挽きたて）", amount: nil),
                    ]),
                    IngredientSection(header: "ガーニッシュ", items: [
                        Ingredient(name: "サワークリーム", amount: nil),
                        Ingredient(name: "フレッシュディル", amount: nil),
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(header: "ビーツ漬けサーモン", items: [
                    CookingStep(stepNumber: 1, instruction: "すりおろしたビーツ、ディル、塩、砂糖、こしょうを混ぜてキュア液を作る。サーモン全体にまんべんなく塗り、クッキングシートでしっかり包んで冷蔵庫に入れ、重しを乗せて3〜4日間寝かせる。2日目にサーモンを裏返す。"),
                    CookingStep(stepNumber: 2, instruction: "サーモンからキュア液を取り除き、繊維に逆らって薄くスライスする。残りのサーモンはラップで包んで冷蔵保存（4〜5日保存可能）。"),
                ]),
                CookingStepSection(header: "ラトケス", items: [
                    CookingStep(stepNumber: 3, instruction: "ボウルにティータオルを敷き、じゃがいもと玉ねぎをすりおろす。タオルで包んで余分な水分をしっかり絞る。絞った液を少し置き、上澄みを捨てて底に沈んだ白いでんぷんを残す。すりおろした野菜と溶き卵、薄力粉、塩を混ぜ合わせる。"),
                    CookingStep(stepNumber: 4, instruction: "フライパンに油を入れ、中強火で熱する。ポテト生地を約120ミリリットルずつ取り、厚さ約1.3センチメートルの円形に整え、6〜7分きつね色になるまで揚げ焼きにする。裏返して同様に焼く。ペーパータオルに移し、塩をたっぷり振る。"),
                ]),
                CookingStepSection(header: "盛り付け", items: [
                    CookingStep(stepNumber: 5, instruction: "ラトケスの上にビーツキュアサーモンを2〜3枚のせ、サワークリームをひとさじ添え、フレッシュディルと挽きたてこしょうを散らす。"),
                ])
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/12/14/latkes-with-beet-cured-salmon-lox/")
        ),
        Recipe(
            id: UUID(uuidString: "FF2049A9-09FE-4FD6-B887-8D6A0735E712")!,
            title: "パニプーリ（一から手作り）",
            description: "インドの定番ストリートフード。サクサクのセモリナ粉シェルにスパイス入りポテトを詰め、ミントウォーターとタマリンドチャツネをかけて仕上げます。",
            imageURLs: [.bundled(name: "seed-pani-poori")],
            ingredientsInfo: Ingredients(
                servings: nil,
                sections: [
                    IngredientSection(header: "プーリの生地用", items: [
                        Ingredient(name: "セモリナ粉", amount: "1カップ"),
                        Ingredient(name: "ベーキングソーダ", amount: "小さじ1/8"),
                        Ingredient(name: "薄力粉", amount: "大さじ1"),
                        Ingredient(name: "塩（生地用）", amount: "小さじ1/4"),
                        Ingredient(name: "水", amount: "大さじ6"),
                        Ingredient(name: "油（生地用）", amount: "小さじ1"),
                        Ingredient(name: "揚げ油", amount: nil),
                    ]),
                    IngredientSection(header: "アルー・マサラ用", items: [
                        Ingredient(name: "じゃがいも（中）", amount: "4個"),
                        Ingredient(name: "チリパウダー", amount: "小さじ1/4"),
                        Ingredient(name: "クミン", amount: "小さじ1/2"),
                        Ingredient(name: "コリアンダー", amount: "小さじ1/2"),
                        Ingredient(name: "チャートマサラ", amount: "小さじ1"),
                        Ingredient(name: "塩（ポテト用）", amount: "小さじ1/2"),
                        Ingredient(name: "パクチー（刻み）", amount: "大さじ2"),
                    ]),
                    IngredientSection(header: "パニプーリ水用", items: [
                        Ingredient(name: "パクチー", amount: "1/2カップ"),
                        Ingredient(name: "ミントの葉", amount: "1/2カップ"),
                        Ingredient(name: "青唐辛子", amount: "2〜3本"),
                        Ingredient(name: "しょうが（皮をむく）", amount: "2.5センチ"),
                        Ingredient(name: "レモン果汁", amount: "1個分"),
                        Ingredient(name: "タマリンドペースト", amount: "大さじ3"),
                        Ingredient(name: "ブラウンシュガーまたはジャガリー", amount: "大さじ3"),
                        Ingredient(name: "チャートマサラ（お好みで）", amount: "小さじ1"),
                        Ingredient(name: "塩", amount: "ひとつまみ"),
                    ]),
                    IngredientSection(header: "ガーニッシュ用", items: [
                        Ingredient(name: "タマリンドチャツネ", amount: nil),
                        Ingredient(name: "ザクロの実", amount: nil),
                        Ingredient(name: "赤玉ねぎ", amount: nil),
                        Ingredient(name: "フレッシュパクチー", amount: nil),
                    ]),
                ]
            ),
            stepSections: [
                CookingStepSection(header: "プーリ生地", items: [
                    CookingStep(stepNumber: 1, instruction: "ボウルにセモリナ粉、ベーキングソーダ、薄力粉、塩を入れて混ぜる。水と油を加え、なめらかで弾力が出るまでこねる。1時間休ませる。"),
                    CookingStep(stepNumber: 2, instruction: "生地を約3ミリの薄さに伸ばし、直径5センチの丸型で抜く。"),
                    CookingStep(stepNumber: 3, instruction: "油を200℃に熱し、生地を揚げる。ぷっくり膨らんできつね色になったら取り出し、油を切る。"),
                ]),
                CookingStepSection(header: "水", items: [
                    CookingStep(stepNumber: 4, instruction: "パクチー、ミントの葉、青唐辛子、しょうが、レモン果汁をミキサーでなめらかになるまで撹拌する。タマリンドペースト、ブラウンシュガー、チャートマサラ、塩ひとつまみを加えて混ぜ、冷水4カップを加えて冷やす。"),
                ]),
                CookingStepSection(header: "じゃがいも", items: [
                    CookingStep(stepNumber: 5, instruction: "じゃがいもを1センチ角に切り、柔らかくなるまで茹でる。水を切り、チリパウダー、クミン、コリアンダー、チャートマサラ、塩、刻みパクチーを加えて和える。"),
                ]),
                CookingStepSection(header: "組み立て", items: [
                    CookingStep(stepNumber: 6, instruction: "プーリのシェルに穴を開け、スパイスポテトを詰める。ミントウォーター、刻んだ赤玉ねぎ、タマリンドチャツネ、ザクロの実、フレッシュパクチーをトッピングし、すぐに提供する。"),
                ]),
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/02/08/pani-poori-from-scratch/")
        ),
        Recipe(
            id: UUID(uuidString: "76C97FB2-26AB-4922-BE3A-235D488B8155")!,
            title: "キャラメルアップルパイ・スティッキーバンズ",
            description: "アップルパイとシナモンロールを融合させた贅沢なスイーツ。スパイス入りアップルバターとくるみを巻き込んだふわふわの生地に、自家製キャラメルとりんごをトッピング。",
            imageURLs: [.bundled(name: "seed-apple-pie-sticky-buns")],
            ingredientsInfo: Ingredients(
                servings: "6個分",
                sections: [
                    IngredientSection(header: "生地用", items: [
                        Ingredient(name: "牛乳", amount: "120ミリリットル"),
                        Ingredient(name: "グラニュー糖", amount: "50グラム"),
                        Ingredient(name: "ドライイースト", amount: "1袋（約7グラム）"),
                        Ingredient(name: "バター（角切り・室温に戻す）", amount: "60グラム"),
                        Ingredient(name: "卵（室温に戻す）", amount: "1個"),
                        Ingredient(name: "塩", amount: "小さじ¼"),
                        Ingredient(name: "薄力粉", amount: "250グラム"),
                    ]),
                    IngredientSection(header: "フィリング用", items: [
                        Ingredient(name: "アップルバター", amount: "120ミリリットル"),
                        Ingredient(name: "ダークブラウンシュガー", amount: "大さじ2"),
                        Ingredient(name: "シナモン", amount: "小さじ¼"),
                        Ingredient(name: "クローブパウダー", amount: "小さじ⅛"),
                        Ingredient(name: "オールスパイスパウダー", amount: "小さじ⅛"),
                        Ingredient(name: "ナツメグ（すりおろし）", amount: "少々"),
                        Ingredient(name: "塩", amount: "少々"),
                        Ingredient(name: "くるみ（細かく刻む）", amount: "60グラム"),
                    ]),
                    IngredientSection(header: "キャラメルアップル用", items: [
                        Ingredient(name: "グラニュー糖（キャラメル用）", amount: "150グラム"),
                        Ingredient(name: "有塩バター（冷たいまま角切り）", amount: "60グラム"),
                        Ingredient(name: "りんご（ピンクレディー・皮をむき芯を取り薄切り）", amount: "1個"),
                    ]),
                    IngredientSection(header: "その他", items: [
                        Ingredient(name: "溶き卵（塗り用）", amount: "1個"),
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(items: [
                    CookingStep(stepNumber: 1, instruction: "牛乳を32〜40℃に温め、スタンドミキサーのボウルに砂糖・イーストと合わせる。5〜10分置いて泡立つまで待つ。"),
                    CookingStep(stepNumber: 2, instruction: "室温に戻したバター、卵、塩を加える。低速で粉を少しずつ加えて生地をまとめ、中高速で5分間こねて滑らかで弾力のある生地にする。"),
                    CookingStep(stepNumber: 3, instruction: "生地を丸めて油を塗ったボウルに入れ、ラップをかけて1時間、2倍の大きさになるまで発酵させる。"),
                    CookingStep(stepNumber: 4, instruction: "フィリングを作る。アップルバターにブラウンシュガー、シナモン、クローブ、オールスパイス、ナツメグ、塩を混ぜ合わせる。"),
                    CookingStep(stepNumber: 5, instruction: "生地を25×30センチメートルの長方形に伸ばし、フィリングを均一に塗り、くるみを散らしてきつく巻く。6等分に切る。直径23センチメートルのパイ皿に油を塗る。"),
                    CookingStep(stepNumber: 6, instruction: "キャラメルを作る。砂糖を中強火で4分間触らずに加熱し、1〜2分かき混ぜて濃い琥珀色にする。火を止めて冷たいバターを加えて混ぜる。パイ皿に流し入れ、りんごのスライスを並べ、その上にバンズを切り口を上にして置く。ホイルをかけて30分発酵させる。"),
                    CookingStep(stepNumber: 7, instruction: "オーブンを190℃に予熱する。バンズに溶き卵を塗り、25分間きつね色になるまで焼く。15〜30分冷ましてから、サービングプレートにひっくり返す。"),
                ])
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2021/03/24/caramel-apple-pie-sticky-buns/")
        ),
        Recipe(
            id: UUID(uuidString: "3D872087-1606-42EA-B839-013A53E875F1")!,
            title: "チキンティッカ",
            description: "2段階のマリネで仕上げる、ジューシーで風味豊かなチキンティッカ。手作りのロティとミントチャツネを添えて。",
            imageURLs: [.bundled(name: "seed-chicken-tikka")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "鶏むね肉（骨なし）", amount: "約900グラム"),
                    Ingredient(name: "ジンジャーペースト", amount: "大さじ1"),
                    Ingredient(name: "ガーリックペースト", amount: "大さじ1"),
                    Ingredient(name: "カシミリチリパウダー", amount: "小さじ2"),
                    Ingredient(name: "塩", amount: "小さじ1"),
                    Ingredient(name: "レモン汁", amount: "大さじ2"),
                    Ingredient(name: "ココナッツミルク", amount: "240ミリリットル"),
                    Ingredient(name: "ジンジャーペースト", amount: "大さじ1"),
                    Ingredient(name: "ガーリックペースト", amount: "大さじ1"),
                    Ingredient(name: "クミンパウダー", amount: "小さじ2"),
                    Ingredient(name: "カシミリチリパウダー", amount: "小さじ2"),
                    Ingredient(name: "ガラムマサラパウダー", amount: "小さじ1"),
                    Ingredient(name: "ターメリック", amount: "大さじ1"),
                    Ingredient(name: "グリーンカルダモンパウダー", amount: "小さじ1/4"),
                    Ingredient(name: "コリアンダーパウダー", amount: "小さじ1"),
                    Ingredient(name: "赤色食用色素（お好みで）", amount: "8滴"),
                    Ingredient(name: "植物油", amount: "60ミリリットル"),
                    Ingredient(name: "赤パプリカ（2.5センチ角に切る）", amount: "1個"),
                    Ingredient(name: "緑パプリカ（2.5センチ角に切る）", amount: "1個"),
                    Ingredient(name: "赤玉ねぎ（大・2.5センチ角に切る）", amount: "1個"),
                    Ingredient(name: "ミントチャツネ", amount: "1回分"),
                    Ingredient(name: "ロティ", amount: "1回分"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "大きなボウルに鶏肉、ジンジャーペースト、ガーリックペースト、カシミリチリパウダー、塩、レモン汁を入れ、手でしっかり揉み込む。室温で20分置く。"),
                CookingStep(stepNumber: 2, instruction: "別のボウルにココナッツミルク、ジンジャーペースト、ガーリックペースト、クミンパウダー、カシミリチリパウダー、ガラムマサラ、ターメリック、グリーンカルダモンパウダー、コリアンダーパウダー、赤色食用色素を混ぜ合わせる。鶏肉を移し、全体にしっかり絡める。ラップをして冷蔵庫で6時間以上（できれば一晩）漬け込む。"),
                CookingStep(stepNumber: 3, instruction: "木製の串を水に20分浸す。漬け込んだ鶏肉を串に刺し、玉ねぎとパプリカを交互に挟む。冷蔵庫に戻す。残ったマリネ液に植物油120ミリリットルを混ぜ、塗り用のタレを作る。"),
                CookingStep(stepNumber: 4, instruction: "オーブンをブロイラー（上火強火）に設定し、天板を最上段にセットする。油を塗った天板に串を並べ、片面3〜4分ずつ焼く。裏返す際にマリネ液を塗り、表面に焦げ目がつき中まで火が通るまで焼く。"),
                CookingStep(stepNumber: 5, instruction: "焼き上がったらすぐにロティとミントチャツネを添えて盛り付ける。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/10/22/chicken-tikka/")
        ),
        Recipe(
            id: UUID(uuidString: "DCCC4552-649C-4B6A-9715-A833C208C138")!,
            title: "スイカとフェタチーズのルッコラサラダ",
            description: "甘いスイカ、ピリッとしたルッコラ、フェタチーズを、柑橘バルサミコくるみドレッシングで和えた爽やかなサラダです。",
            imageURLs: [.bundled(name: "seed-watermelon-feta-salad")],
            ingredientsInfo: Ingredients(
                servings: nil,
                sections: [IngredientSection(items: [
                    Ingredient(name: "レモン汁", amount: "大さじ2"),
                    Ingredient(name: "オレンジジュース", amount: "大さじ2"),
                    Ingredient(name: "レモンの皮（すりおろし）", amount: "小さじ1"),
                    Ingredient(name: "オレンジの皮（すりおろし）", amount: "小さじ1"),
                    Ingredient(name: "バルサミコ酢", amount: "大さじ2"),
                    Ingredient(name: "オリーブオイル", amount: "小さじ3"),
                    Ingredient(name: "塩", amount: "小さじ1/2"),
                    Ingredient(name: "こしょう", amount: "小さじ1/2"),
                    Ingredient(name: "くるみ（刻み）", amount: "大さじ2"),
                    Ingredient(name: "スイカ（2.5センチ角）", amount: "5カップ"),
                    Ingredient(name: "ベビールッコラ", amount: "3カップ"),
                    Ingredient(name: "フェタチーズ（砕く）", amount: "1/4カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "大きなボウルにレモン汁、オレンジジュース、レモンの皮、オレンジの皮、バルサミコ酢、オリーブオイル、塩、こしょう、刻みくるみを入れてよく混ぜ合わせます。"),
                CookingStep(stepNumber: 2, instruction: "スイカ、ベビールッコラ、砕いたフェタチーズを加えます。"),
                CookingStep(stepNumber: 3, instruction: "ドレッシングが全体に行き渡るようにさっくりと和え、すぐに盛り付けます。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2020/09/06/watermelon-feta-arugula-salad/")
        ),
        Recipe(
            id: UUID(uuidString: "E3CE7FFB-A44D-462C-BD5C-8893B4BD893A")!,
            title: "ポップコーンチキン 2種のソース添え 自家製ピクルス付き",
            description: "韓国フライドチキンにインスパイアされたカリカリのポップコーンチキンを、甘いハニーマスタードソースとスパイシーなコチュジャンバッファローソースの2種で楽しむ一品。自家製ピクルスを添えて。",
            imageURLs: [.bundled(name: "seed-popcorn-chicken")],
            ingredientsInfo: Ingredients(
                servings: "4〜6人分",
                sections: [
                    IngredientSection(header: "ピクル用", items: [
                        Ingredient(name: "キュウリ（カービー種）、3ミリ厚にスライス", amount: "3本"),
                        Ingredient(name: "玉ねぎ（薄切り）", amount: "½カップ"),
                        Ingredient(name: "ホワイトビネガー", amount: "1カップ"),
                        Ingredient(name: "セロリシード", amount: "小さじ1"),
                        Ingredient(name: "マスタードシード", amount: "小さじ2"),
                        Ingredient(name: "砂糖", amount: "½カップ"),
                        Ingredient(name: "コーシャーソルト", amount: "小さじ1"),
                        Ingredient(name: "ターメリック", amount: "小さじ¼"),
                    ]),
                    IngredientSection(header: "ハニーマスタードソース用", items: [
                        Ingredient(name: "ディジョンマスタード", amount: "¼カップ"),
                        Ingredient(name: "粒マスタード", amount: "大さじ2"),
                        Ingredient(name: "はちみつ", amount: "¼カップ"),
                        Ingredient(name: "にんにく（すりおろし）", amount: "4片"),
                    ]),
                    IngredientSection(header: "バッファローソース用", items: [
                        Ingredient(name: "フランクスレッドホットソース", amount: "½カップ"),
                        Ingredient(name: "コチュジャン", amount: "大さじ2〜4"),
                        Ingredient(name: "バター（植物性推奨）", amount: "大さじ2"),
                    ]),
                    IngredientSection(header: "チキン用", items: [
                        Ingredient(name: "鶏肉（骨なしむね肉またはもも肉）", amount: "約900グラム"),
                        Ingredient(name: "コーンスターチまたは片栗粉", amount: "1カップ"),
                    ])
                ]
            ),
            stepSections: [
                CookingStepSection(header: "ピクル作り", items: [
                    CookingStep(stepNumber: 1, instruction: "スライスしたキュウリと薄切り玉ねぎをボウルに合わせ、1クォートサイズの容器に移す。"),
                    CookingStep(stepNumber: 2, instruction: "鍋にマスタードシードとセロリシードを入れ、弱火で30秒〜1分、香りが立つまで炒る。ビネガー、砂糖、塩を加え、溶けるまで煮立たせたら火を止める。"),
                    CookingStep(stepNumber: 3, instruction: "氷を加えて混ぜ、溶けたらピクルスの上に注ぐ。蓋をして冷蔵庫で最低12時間漬ける。"),
                ]),
                CookingStepSection(header: "ハニーマスタードソース作り", items: [
                    CookingStep(stepNumber: 4, instruction: "浅いボウルにディジョンマスタード、粒マスタード、はちみつ、すりおろしにんにくを入れてよく混ぜ、ハニーマスタードソースを作る。"),
                ]),
                CookingStepSection(header: "バッファローソース作り", items: [
                    CookingStep(stepNumber: 5, instruction: "別の浅いボウルにフランクスレッドホットソース、コチュジャン、バターを入れてよく混ぜ、バッファローソースを作る。"),
                ]),
                CookingStepSection(header: "チキン調理", items: [
                    CookingStep(stepNumber: 6, instruction: "天板2枚にペーパータオルを敷く。ダッチオーブンに植物油を約7センチの深さまで入れ、160℃に熱する。"),
                    CookingStep(stepNumber: 7, instruction: "スターチに大さじ2の水を加え、小石状のかたまりができるまで混ぜる。鶏肉を一口大に切り、スターチをまぶす。"),
                    CookingStep(stepNumber: 8, instruction: "鶏肉を数回に分けて3〜4分揚げ、端がうっすらきつね色になったら1枚目の天板に取り出す。"),
                    CookingStep(stepNumber: 9, instruction: "油の温度を200℃に上げ、鶏肉を再度2〜3分揚げてきつね色にする。2枚目の天板に取り出し、塩をふる。"),
                ]),
                CookingStepSection(header: "盛り付けと提供", items: [
                    CookingStep(stepNumber: 10, instruction: "揚げたての鶏肉を2種のソースのボウルに分け入れ、しっかり絡める。自家製ピクルスを添えて温かいうちにいただく。"),
                ])
            ],
            sourceURL: URL(string: "https://www.eitanbernath.com/2022/12/09/popcorn-chicken-two-ways-with-homemade-pickles/")
        ),
        Recipe(
            id: UUID(uuidString: "835117FB-65FC-49F4-8C33-E6CDC9A0236B")!,
            title: "マッシュルームとグリッツ",
            description: "南部料理の定番シュリンプ＆グリッツを植物ベースにアレンジ。ピンクオイスターマッシュルームとクリーミーなチェダーグリッツの組み合わせ。",
            imageURLs: [.bundled(name: "seed-shrooms-and-grits")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [
                    IngredientSection(header: "グリッツ用", items: [
                        Ingredient(name: "石挽きグリッツ", amount: "1カップ"),
                        Ingredient(name: "ハーフアンドハーフ", amount: "1カップ"),
                        Ingredient(name: "バター", amount: "大さじ2"),
                        Ingredient(name: "シャープホワイトチェダーチーズ（すりおろし）", amount: "1カップ（100グラム）"),
                        Ingredient(name: "塩・黒こしょう", amount: "適量"),
                    ]),
                    IngredientSection(header: "マッシュルーム用", items: [
                        Ingredient(name: "バター（分けて使う）", amount: "大さじ4"),
                        Ingredient(name: "ピンクオイスターマッシュルーム（一口大にカット）", amount: "約1リットル"),
                        Ingredient(name: "赤パプリカ（細かく刻む）", amount: "1個（180グラム）"),
                        Ingredient(name: "スキャリオン（白い部分は細かく刻み、緑の部分は斜め切り）", amount: "1束（100グラム）"),
                        Ingredient(name: "ローマトマト（細かく刻む）", amount: "1個（75グラム）"),
                        Ingredient(name: "にんにく（みじん切り）", amount: "3片（15グラム）"),
                        Ingredient(name: "スモークパプリカ", amount: "小さじ½"),
                        Ingredient(name: "カイエンペッパー", amount: "小さじ⅛"),
                        Ingredient(name: "薄力粉", amount: "大さじ1"),
                        Ingredient(name: "野菜ブイヨン", amount: "1カップ"),
                        Ingredient(name: "レモン汁", amount: "仕上げ用"),
                    ])
                ]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "塩を加えた湯を沸騰させ、グリッツをゆっくりと加えながら絶えずかき混ぜる。火を弱めて約1分間混ぜ続け、とろみがついたらハーフアンドハーフをゆっくり加える。弱火にして15〜20分、時々かき混ぜながらクリーミーになるまで煮る。チェダーチーズを4回に分けて加え、その都度よく混ぜる。バターを加え、黒こしょうで味を調え、塩加減を整える。蓋をして置いておく。"),
                CookingStep(stepNumber: 2, instruction: "大きなスキレットにバター大さじ1を中強火で熱する。マッシュルームを重ならないように並べ、片面約1分ずつ焼き色をつける。バッチに分けて焼き、必要に応じてバターを追加する。焼けたら皿に取り出す。"),
                CookingStep(stepNumber: 3, instruction: "同じスキレットにバター大さじ1を加える。スキャリオンの白い部分と赤パプリカを柔らかく半透明になるまで8〜10分炒める。にんにく、トマト、スモークパプリカ、カイエンペッパーを加え、香りが立つまで2〜3分炒める。薄力粉を振り入れて1〜2分混ぜ、野菜ブイヨンを少しずつ加えながら混ぜる。2〜3分煮て軽くとろみをつけ、味を調える。"),
                CookingStep(stepNumber: 4, instruction: "マッシュルームと溜まった肉汁をフライパンに戻し、約2分温める。"),
                CookingStep(stepNumber: 5, instruction: "グリッツの濃度を確認する。必要に応じて弱火でハーフアンドハーフを追加し、好みの固さになるまで混ぜる。"),
                CookingStep(stepNumber: 6, instruction: "グリッツをボウルに盛り分け、マッシュルームのソースをのせる。スキャリオンの緑の部分とレモン汁を添えて仕上げる。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2022/10/28/shrooms-and-grits/")
        ),
        Recipe(
            id: UUID(uuidString: "C8DA5326-E776-40D6-B887-7FCA48682451")!,
            title: "ラズベリー バルサミコ リフレッシャー",
            description: "シュラブ（果実酢ドリンク）の手法にインスピレーションを得た、フレッシュラズベリーとホワイトバルサミコ酢、ミントを組み合わせた爽やかなノンアルコールドリンクです。",
            imageURLs: [.bundled(name: "seed-raspberry-balsamic-refresher")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "グラニュー糖", amount: "½カップ"),
                    Ingredient(name: "フレッシュミントの葉（しっかり詰めて）", amount: "½カップ"),
                    Ingredient(name: "ラズベリー（約3カップ分）", amount: "2パック（各170グラム）"),
                    Ingredient(name: "ライム果汁", amount: "1個分（¼カップ）"),
                    Ingredient(name: "ホワイトバルサミコ酢", amount: "¼カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "小鍋にグラニュー糖、水½カップ、ミントを入れて中火にかける。砂糖が溶けるまで煮たら、1時間かけて完全に冷ます。ピッチャーに濾し入れる。"),
                CookingStep(stepNumber: 2, instruction: "ラズベリーをフードプロセッサーでなめらかになるまで撹拌する。目の細かいストレーナーでピッチャーに濾し入れ、種を取り除く。"),
                CookingStep(stepNumber: 3, instruction: "ライム果汁、ホワイトバルサミコ酢、氷水3カップを加え、しっかり混ぜ合わせる。"),
                CookingStep(stepNumber: 4, instruction: "提供するまで冷蔵庫で冷やす。グラスに氷を入れて注ぐ。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2022/09/02/raspberry-balsamic-refresher/")
        ),
        Recipe(
            id: UUID(uuidString: "13BA66F2-D9F3-4A0B-B8BB-9E8671DD38FC")!,
            title: "エンゼルフードケーキ マセレーテッドストロベリー添え",
            description: "バニラとアーモンドが香るふわふわの軽いケーキに、ブランデーで漬けた甘いいちごとホイップクリームを添えた、おもてなしにぴったりのデザートです。",
            imageURLs: [.bundled(name: "seed-angel-food-cake")],
            ingredientsInfo: Ingredients(
                servings: "10〜12人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "グラニュー糖", amount: "1と3/4カップ（350グラム）"),
                    Ingredient(name: "薄力粉（ケーキフラワー）", amount: "1カップ（133グラム）"),
                    Ingredient(name: "コーシャーソルト", amount: "小さじ1/4"),
                    Ingredient(name: "卵白（常温）", amount: "12個分"),
                    Ingredient(name: "クリームオブタータ―", amount: "小さじ1と1/2"),
                    Ingredient(name: "バニラエキストラクト", amount: "小さじ1"),
                    Ingredient(name: "アーモンドエキストラクト", amount: "小さじ1/2"),
                    Ingredient(name: "いちご（4等分に切る）", amount: "450グラム"),
                    Ingredient(name: "砂糖（ベリー用）", amount: "大さじ1〜2"),
                    Ingredient(name: "ブランデーまたはポートワイン", amount: "大さじ2"),
                    Ingredient(name: "ホイップクリーム（お好みで）", amount: nil),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "オーブンを160℃に予熱する。"),
                CookingStep(stepNumber: 2, instruction: "グラニュー糖をブレンダーでパウダー状になるまで撹拌する。半分に分け、片方を薄力粉・塩とボウルで混ぜ合わせておく。"),
                CookingStep(stepNumber: 3, instruction: "スタンドミキサーにホイッパーを付け、卵白とクリームオブターターを中速で泡立てる。泡立ってきたら残りの砂糖を少しずつ加え、角がやわらかくお辞儀する程度（ミディアムピーク）まで泡立てる。バニラエキストラクトとアーモンドエキストラクトを折り込む。"),
                CookingStep(stepNumber: 4, instruction: "粉類を3回に分けて卵白に加え、生地がしぼまないようにやさしく折り込む。"),
                CookingStep(stepNumber: 5, instruction: "油を塗っていないチューブ型（エンゼル型）に生地を流し入れる。"),
                CookingStep(stepNumber: 6, instruction: "40〜45分焼く。つまようじを刺して生地が付いてこなければ焼き上がり。"),
                CookingStep(stepNumber: 7, instruction: "型をひっくり返し、逆さのまま最低2時間冷ます。"),
                CookingStep(stepNumber: 8, instruction: "ケーキを冷ましている間に、4等分に切ったいちごに砂糖をまぶし、30分漬ける。その後ブランデーまたはポートワインを加えて中火で6〜8分煮る。ベリーが柔らかくなり、液体が少しとろりとするまで加熱する。"),
                CookingStep(stepNumber: 9, instruction: "ナイフやオフセットスパチュラを使い、型の側面と中央の筒からケーキを丁寧にはがす。"),
                CookingStep(stepNumber: 10, instruction: "ケーキをサービングトレイにひっくり返して取り出す。波刃のナイフでやさしく前後に動かしながら切り分ける。"),
                CookingStep(stepNumber: 11, instruction: "切り分けたケーキにマセレーテッドストロベリーとホイップクリームをのせ、すぐにいただく。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2022/06/24/angel-food-cake-with-macerated-strawberries/")
        ),
        Recipe(
            id: UUID(uuidString: "4B420A85-4CD3-4DFC-A57A-797BA5DC0A49")!,
            title: "インド風ブレックファストブリトー",
            description: "手作りロティにミントチャツネ、チャートマサラ味のハッシュブラウン、チリパニール、クミンスクランブルエッグを包んだフュージョン朝食ブリトー。",
            imageURLs: [.bundled(name: "seed-indian-breakfast-burrito")],
            ingredientsInfo: Ingredients(
                servings: "4人分",
                sections: [IngredientSection(items: [
                    Ingredient(name: "全粒粉（細挽き）", amount: "3カップ"),
                    Ingredient(name: "コーシャーソルト", amount: "小さじ1"),
                    Ingredient(name: "植物油", amount: "大さじ1"),
                    Ingredient(name: "ギーまたはバター（溶かし）", amount: "¼カップ"),
                    Ingredient(name: "ミントの葉", amount: "1½カップ"),
                    Ingredient(name: "パクチーの葉と柔らかい茎", amount: "1カップ"),
                    Ingredient(name: "インド産青唐辛子（小）", amount: "1本"),
                    Ingredient(name: "黄玉ねぎ（小）", amount: "½個"),
                    Ingredient(name: "レモン（搾り汁）", amount: "1個"),
                    Ingredient(name: "生姜（皮をむく）", amount: "約1.5センチ"),
                    Ingredient(name: "にんにく（皮をむく）", amount: "2片"),
                    Ingredient(name: "クミン", amount: "小さじ½"),
                    Ingredient(name: "ラセットポテト", amount: "2個"),
                    Ingredient(name: "植物油", amount: "大さじ2"),
                    Ingredient(name: "コーシャーソルト", amount: "適量"),
                    Ingredient(name: "黒こしょう（挽きたて）", amount: "適量"),
                    Ingredient(name: "チャートマサラ", amount: "小さじ2"),
                    Ingredient(name: "植物油", amount: "¼カップ"),
                    Ingredient(name: "赤パプリカ（角切り）", amount: "1個"),
                    Ingredient(name: "インド産青唐辛子（小・刻み）", amount: "2本"),
                    Ingredient(name: "パニール（角切り）", amount: "2パック（各約225グラム）"),
                    Ingredient(name: "カシミールチリパウダー", amount: "小さじ2"),
                    Ingredient(name: "ターメリックパウダー", amount: "小さじ1"),
                    Ingredient(name: "クミン", amount: "小さじ1"),
                    Ingredient(name: "コリアンダー", amount: "小さじ1"),
                    Ingredient(name: "バター", amount: "大さじ2"),
                    Ingredient(name: "クミンシード", amount: "小さじ1"),
                    Ingredient(name: "卵（よく溶く）", amount: "4個"),
                    Ingredient(name: "塩・こしょう", amount: "適量"),
                    Ingredient(name: "赤玉ねぎ（薄切り）", amount: "½個"),
                    Ingredient(name: "パクチーの葉", amount: "½カップ"),
                ])]
            ),
            stepSections: [CookingStepSection(items: [
                CookingStep(stepNumber: 1, instruction: "ロティ生地を作る：ボウルに小麦粉、塩、油を入れて混ぜる。水1カップを加えて生地がまとまるまで混ぜ、3〜4分こねて滑らかにする。ラップをして20分以上休ませる。"),
                CookingStep(stepNumber: 2, instruction: "生地を6等分にし、それぞれ端を内側に折り込みながら丸く成形する。乾燥しないように覆っておく。"),
                CookingStep(stepNumber: 3, instruction: "打ち粉をした台の上で各生地を直径約30センチの円形に伸ばす。中心から外側へ麺棒を転がし、45度ずつ回転させながら均一に伸ばす。"),
                CookingStep(stepNumber: 4, instruction: "鋳鉄スキレットを裏返して強火で5分予熱する。ロティを片面約1分ずつ、気泡ができてきつね色の焼き目がつくまで焼く。ギーを塗って覆っておく。"),
                CookingStep(stepNumber: 5, instruction: "ミントチャツネを作る：フードプロセッサーにミント、パクチー、青唐辛子、玉ねぎ、レモン汁、生姜、にんにく、クミンを入れて撹拌する。水¼カップを少しずつ加え、ペースト状にする。"),
                CookingStep(stepNumber: 6, instruction: "ハッシュブラウンを作る：じゃがいもを粗くすりおろし、冷水に10分浸す。水気を切り、布巾でしっかり絞る。"),
                CookingStep(stepNumber: 7, instruction: "大きなスキレットに油を入れ強火で熱する。じゃがいもを薄く広げ、塩こしょうで味付け。片面3〜4分ずつきつね色になるまで焼く。火を止めてチャートマサラを混ぜ合わせる。"),
                CookingStep(stepNumber: 8, instruction: "チリパニールを作る：大きなスキレットに油を入れ強火で熱する。赤パプリカと青唐辛子を4〜5分炒める。パニールを加え、4〜5分きつね色になるまで炒める。"),
                CookingStep(stepNumber: 9, instruction: "チリパウダー、ターメリック、クミン、コリアンダーを加えて混ぜ合わせる。塩こしょうで味を調え、さらに1分加熱する。"),
                CookingStep(stepNumber: 10, instruction: "スクランブルエッグを作る：ノンスティックパンにバターを入れ弱火で溶かす。クミンシードを加え、30〜45秒、香りが立つまで炒める。"),
                CookingStep(stepNumber: 11, instruction: "溶き卵を加え、3〜4分絶えずかき混ぜながら、9割ほど固まり少し液体が残る状態で火から下ろす。"),
                CookingStep(stepNumber: 12, instruction: "組み立て：ロティを広げ、中央にハッシュブラウン、チリパニール、スクランブルエッグ、赤玉ねぎ、パクチーを各¼量ずつのせ、ミントチャツネを回しかける。手前から具を包むように折り、両端を折り込んでしっかり巻く。すぐに提供する。"),
            ])],
            sourceURL: URL(string: "https://www.eitanbernath.com/2022/03/25/indian-inspired-breakfast-burrito/")
        ),
    ]
}
