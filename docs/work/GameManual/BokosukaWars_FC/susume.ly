% -*- coding: utf-8 -*-

\version "2.12.3"

\header {
  title = "すすめボコスカ"
}

\paper {
  indent = 0
}

\score {
  <<
    \relative c'' {
      \numericTimeSignature
      \time 4/4
      \key d \minor
      %\tempo 4=100
      \autoBeamOff

      \clef treble
      g8^\mf bes8 c4 g8 bes8 c4 |
      g8 bes8 a4 f4 r4 |
      g8 bes8 c4 g8 bes8 c4 |
      g8 bes8 a4 c4 r4 | \break

      \clef treble
      g8^\f bes8 d4^\< g,8 bes8 d4 |
      g,8 bes8 e2\! r4 |
      d4-.^\ff c4-. bes4-. a4-. |
      d8 c8 bes8 a8 g4 r4 | \bar "|."
    }
    \addlyrics {
      \set fontSize = #-1
      す す め す す め
      も の ど も
      じゃ ま な て き を
      け ち ら せ

      め ざ せ て き の
      し ろ へー
      オ ゴ レ ス
      た お す の だ
    }
  >>

  \layout { }
  \midi { }
}
