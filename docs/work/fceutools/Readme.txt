fceutools
=========

FCEU/FCEUX用のFCM/FM2/FCSファイルを扱うコマンドラインツール集。

  fcmcheck	FCMファイルの正当性チェック、情報表示
  fcmoptim	FCMファイルの最適化(初期ステート無効化、ゴミ除去)
  fm2check	FM2ファイルの正当性チェック、情報表示
  fcmtofm2	FCM -> FM2変換
  fm2tofcm	FM2 -> FCM変換
  fcscheck	FCSファイルの正当性チェック、情報表示
  fcscomp	FCEUX用FCSファイルの圧縮/展開

まだテストが不十分なので、使用する際は元ファイルのバックアップをとっておくこ
とをオススメします。また、処理速度についてあまり考慮していないので少々重いで
す(特にFM2読み込み処理)。

同梱のバイナリはCygwin GCC 3.4.4のMinGWモードでビルドしています。自前でビル
ドする場合、zlibが必要です。


fcmcheck
--------

Usage:
  $ fcmcheck [-v] [-os FCM] [-ob body] <FCM>

FCMファイルの正当性をチェックし、内容に関する情報を表示します。
-v オプションを指定すると、情報表示の前に入力データをダンプします。
-os オプションを指定すると、初期ステートを指定ファイルに出力します。
-ob オプションを指定すると、入力データを指定ファイルに出力します。


fcmoptim
--------

Usage:
  $ fcmoptim <input FCM> <output FCM>

FCMファイルに含まれるゴミを除去し、さらに開始点がステートでない場合は初期ス
テートを無効化(16Byteの空ステートに置換)します。

FCMファイルは仕様上(開始点がステートでなくても)必ず初期ステートを持っており、
また末尾にゴミが付いていることもあるので、ほとんどの場合ファイルサイズを大き
く削減できます(マッパーにもよるが、一般に初期ステートはかなりサイズが大きい)。

また、何らかの原因で初期ステートの内容が異常になったりすると、desyncが起こっ
たり、FM2に変換した際に正しく動かなかったりするので、そうした事態を未然に避
ける目的にも有効です(一度初期ステートを無効化すれば、その後追記を行っても無
効化されたままになります)。


fm2check
--------

Usage:
  $ fm2check [-os FCM] <FCM>

FM2ファイルの正当性をチェックし、内容に関する情報を表示します。
-os オプションを指定すると、初期ステート(あれば)を指定ファイルに出力します。


fcmtofm2
--------

Usage:
  $ fcmtofm2 <FCM> <FM2>

FCMファイルをFM2ファイルに変換します。

ステートから開始するFCMファイルは変換できません。また、ソフトリセットから開
始するFCMはハードリセットから開始するものとして扱います(FCEUXはこれに加えて
最初のフレームにソフトリセットを挿入するので、厳密にはFCEUX上での変換と挙動
が異なります。ただしこれは通常問題にならないと思います)。

今のところ、変換時に作者情報が失われる仕様です(単なる手抜き)。


fm2tofcm
--------

Usage:
  $ fm2tofcm <FM2> <FCM>

FM2ファイルをFCMファイルに変換します。

ステートから開始するFM2ファイルは変換できません。また、FCMファイルの初期ステー
トは16Byteの空ステートとなります(無効化された状態)。

今のところ、変換時に作者情報が失われる仕様です(単なる手抜き)。


fcscheck
--------

Usage:
  $ fcscheck <FCS>

FCSファイルの正当性をチェックし、内容に関する情報を表示します。

FCEUで出力されたFCSファイルはしばしばヘッダに誤ったサイズが書き込まれている
ので、その点に関しては寛容に扱います。


fcscomp
-------

Usage:
  $ fcscomp <c|u> <input FCS> <output FCS>

FCEUX用FCSファイルの圧縮/展開を行います(通常、FCEUXで出力されたFCSファイルは
圧縮されています)。

第1引数に c を指定すると圧縮、u を指定すると展開を行います。


参考資料
--------

* FCEU
  http://code.google.com/p/fceu/
* FCEUX
  http://fceux.com/web/htdocs/
* TASVideos / FCM
  http://tasvideos.org/FCM.html
* TASVideos / FM2
  http://tasvideos.org/FM2.html
* tastools (FCMFix のソースコードあり)
  http://code.google.com/p/tastools/
* Bisqwit's FCM parser
  http://bisqwit.iki.fi/utils/fcmparser.php
