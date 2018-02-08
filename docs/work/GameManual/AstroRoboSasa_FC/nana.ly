% -*- coding: utf-8 -*-

% 元楽譜に誤り(と思われる)が散見されるので修正した(ゲーム上の音楽を耳コピ)。

\version "2.12.2"

\header {
  title = "NANA愛のテーマ"
}

\paper {
  indent = 0
}

\score {
  <<
    \relative c' {
      \time 6/8
      \key c \major
      \clef treble
      %\tempo 4=50
      \tempo 4=75 % ゲーム上の速度に合わせた
      \tieUp
      \slurUp

      e4 c8 g c e | % c4 を c8 に修正
      f4 e8 d4 e8 |
      d4 c8 e4 a8 |
      g4. ~ g4 e8 | \break

      f4. f4 e8 |
      f4 e8 d4 c8 |
      c4. ~ c4. |
      b4. b8 c d | \break

      e4^\segno c8 g c e |
      f4 e8 d4 e8 |
      d4 c8 e4 a8 |
      g4. ~ g4 e8 | \break

      f4. f4 e8 |
      f4 e8 d4 e8 |
      d4. ~ d4. |
      c4. ~ c4.-\markup { \italic "Fine" } \bar "||" | \break % 余分な r8 を除去、"Fin" を "Fine" に修正

      a'4 a8 a gis a |
      b4 a8 g4 f8 |
      e8 gis b d4 b8 |
      c4. r8 b8 c8 | \break

      e4. e |
      c4. a |
      a4. ~ a4 a8 |
      g4. ( dis )-\markup { \italic "D.S." } \bar "||" | % "D.S" を "D.S." に修正
    }
    \addlyrics {
      \set fontSize = #-1
      ね え こ ん な
      は れ た あ
      お い そ ら
      に～ あ

      か い ふ
      う せ ん に
      の～っ
      て ラ ラ ラ

      ね え た び を
      し ま しょう ふ
      た り だ け
      の～ し

      ろ い く
      も に さ そ
      わ～
      れ

      ラ ラ
      _ にじ _
      を こ え て
      そ ら の か な
      た あ な

      た と
      dream in
      パ～ ラ
      ダイス
    }
    \addlyrics {
      \set fontSize = #-1
      _ _ _ _ _
      _ _ _ _
      _ _ _ _
      _ _

      _ _ _
      _ _ _ _
      _
      _ _ _ _


      ね え し っ か
      り て を つ
      な い で い
      て～ ま

      よい ご に
      な ら な い
      よ～
      に
    }
  >>

  \layout { }
  \midi { }
}
