??    C      4  Y   L      ?  ?   ?  9   ;  R   u  b   ?  w   +  ?   ?  ?   q  ~   	  ?   ?	  `   T
  Q   ?
  ?     ?   ?  /   q  M   ?  ]   ?  ?   M  G   ?  H   A  d   ?  ?   ?  b   ?  ?   ?  ?   ?  5   <  6   r  ?   ?  ?   ?  ?   &  ?   ?  ?   ?  r  _  |   ?  ?   O  ?  >  N  ?  ?     ?     ?   ?  ?   X  z  :  J   ?  h       ?   i   p   ?   G  o!  ?   ?"  ?   ;#  ?   ?#  ?   `$  ?   :%  ?   ?%  ?   ?&  ?   w'  ?   :(  ?   ?(  *  w)  ?   ?*  ?   ?+  \   ~,  r   ?,  ?   N-  ?   ?-  ?   ?.  ?   z/  ?  $0    ?1  ?   ?3  ^   g4  m   ?4  a   45  ?   ?5  ,  +6  -  X7  ?   ?8    29  ?   5:  p   ;  ?   ?;    U<  ^   X=  ?   ?=  ?   ?>  Q  ?>  r   @  f   ?@  y   ?@  ?   rA  ?   ;B     ?B  ?   ?C  W   ?D  W   E  @  eE  ?   ?F    zG  ?   ?H  ?   |I  ?  J  ?   ?K  -  cL  ?  ?M  #  OO  ?   sQ  B  SR  ?   ?S  >  ZT    ?U  Q   ?W  ?   ?W  ?   ?X  ?   Y    ?Y    ?[  ?   ?\  ?   ?]  ?   ?^  ?   m_    `  ?   8b  ?   ?b  ?   ?c    ?d  ?  ?e    .g  ?   Nh  u   Mi  ?   ?i  ?   bj  Z  +k  ?   ?l  ?   m  ?  |n         >   "                 ;       6                 (   0      :                    C       +   %          8   '            2              3   .      1   @   )   4   A         5          *   $      7          =   -      #                    9      ?   B   <                   /      &       
          ,   	       !          'Ignore' to continue waiting for the thread to respond.
'Cancel' to attempt to cancel the thread.
'Terminate' to quit PCSX2 immediately.
 0 - Disables VU Cycle Stealing.  Most compatible setting! 1 - Mild VU Cycle Stealing.  Lower compatibility, but some speedup for most games. 2 - Moderate VU Cycle Stealing.  Even lower compatibility, but significant speedups in some games. 3 - Maximum VU Cycle Stealing.  Usefulness is limited, as this will cause flickering visuals or slowdown in most games. All plugins must have valid selections for %s to run.  If you are unable to make a valid selection due to missing plugins or an incomplete install of %s, then press Cancel to close the Configuration panel. Avoids memory card corruption by forcing games to re-index card contents after loading from savestates.  May not be compatible with all games (Guitar Hero). Check HDLoader compatibility lists for known games that have issues with this. (Often marked as needing 'mode 1' or 'slow DVD' Check this to force the mouse cursor invisible inside the GS window; useful if using the mouse as a primary control device for gaming.  By default the mouse auto-hides after 2 seconds of inactivity. Completely closes the often large and bulky GS window when pressing ESC or pausing the emulator. Enable this if you think MTGS thread sync is causing crashes or graphical errors. Enables automatic mode switch to fullscreen when starting or resuming emulation. You can still toggle fullscreen display at any time using alt-enter. Existing %s settings have been found in the configured settings folder.  Would you like to import these settings or overwrite them with %s default values?

(or press Cancel to select a different settings folder) Failed: Destination memory card '%s' is in use. Failed: Duplicate is only allowed to an empty PS2-Port or to the file system. Known to affect following games:
 * Bleach Blade Battler
 * Growlanser II and III
 * Wizardry Known to affect following games:
 * Digital Devil Saga (Fixes FMV and crashes)
 * SSX (Fixes bad graphics and crashes)
 * Resident Evil: Dead Aim (Causes garbled textures) Known to affect following games:
 * Mana Khemia 1 (Going "off campus")
 Known to affect following games:
 * Test Drive Unlimited
 * Transformers NTFS compression can be changed manually at any time by using file properties from Windows Explorer. NTFS compression is built-in, fast, and completely reliable; and typically compresses memory cards very well (this option is highly recommended). Note that when Framelimiting is disabled, Turbo and SlowMotion modes will not be available either. Note: Recompilers are not necessary for PCSX2 to run, however they typically improve emulation speed substantially. You may have to manually re-enable the recompilers listed above, if you resolve the errors. Notice: Due to PS2 hardware design, precise frame skipping is impossible. Enabling it will cause severe graphical errors in some games. Notice: Most games are fine with the default options. Notice: Most games are fine with the default options.  Out of Memory (sorta): The SuperVU recompiler was unable to reserve the specific memory ranges required, and will not be available for use.  This is not a critical error, since the sVU rec is obsolete, and you should use microVU instead anyway. :) PCSX2 is unable to allocate memory needed for the PS2 virtual machine. Close out some memory hogging background tasks and try again. PCSX2 requires a *legal* copy of the PS2 BIOS in order to run games.
You cannot use a copy obtained from a friend or the Internet.
You must dump the BIOS from your *own* Playstation 2 console. PCSX2 requires a PS2 BIOS in order to run.  For legal reasons, you *must* obtain a BIOS from an actual PS2 unit that you own (borrowing doesn't count).  Please consult the FAQs and Guides for further instructions. Playstation game discs are not supported by PCSX2.  If you want to emulate PSX games then you'll have to download a PSX-specific emulator, such as ePSXe or PCSX. Please ensure that these folders are created and that your user account is granted write permissions to them -- or re-run PCSX2 with elevated (administrator) rights, which should grant PCSX2 the ability to create the necessary folders itself.  If you do not have elevated rights on this computer, then you will need to switch to User Documents mode (click button below). Please select a valid BIOS.  If you are unable to make a valid selection then press Cancel to close the Configuration panel. Please select your preferred default location for PCSX2 user-level documents below (includes memory cards, screenshots, settings, and savestates).  These folder locations can be overridden at any time using the Plugin/BIOS Selector panel. Primarily targetting the EE idle loop at address 0x81FC0 in the kernel, this hack attempts to detect loops whose bodies are guaranteed to result in the same machine state for every iteration until a scheduled event triggers emulation of another unit.  After a single iteration of such loops, we advance to the time of the next event or the end of the processor's timeslice, whichever comes first. Removes any benchmark noise caused by the MTGS thread or GPU overhead.  This option is best used in conjunction with savestates: save a state at an ideal scene, enable this option, and re-load the savestate.

Warning: This option can be enabled on-the-fly but typically cannot be disabled on-the-fly (video will typically be garbage). Runs VU1 on its own thread (microVU1-only). Generally a speedup on CPUs with 3 or more cores. This is safe for most games, but a few games are incompatible and may hang. In the case of GS limited games, it may be a slowdown (especially on dual core CPUs). Speedhacks usually improve emulation speed, but can cause glitches, broken audio, and false FPS readings.  When having emulation problems, disable this panel first. The PS2-slot %d has been automatically disabled.  You can correct the problem
and re-enable it at any time using Config:Memory cards from the main menu. The Presets apply speed hacks, some recompiler options and some game fixes known to boost speed.
Known important game fixes will be applied automatically.

--> Uncheck to modify settings manually (with current preset as base) The Presets apply speed hacks, some recompiler options and some game fixes known to boost speed.
Known important game fixes will be applied automatically.

Presets info:
1 -     The most accurate emulation but also the slowest.
3 --> Tries to balance speed with compatibility.
4 -     Some more aggressive hacks.
6 -     Too many hacks which will probably slow down most games.
 The specified path/directory does not exist.  Would you like to create it? The thread '%s' is not responding.  It could be deadlocked, or it might just be running *really* slowly. There is not enough virtual memory available, or necessary virtual memory mappings have already been reserved by other processes, services, or DLLs. This action will reset the existing PS2 virtual machine state; all current progress will be lost.  Are you sure? This command clears %s settings and allows you to re-run the First-Time Wizard.  You will need to manually restart %s after this operation.

WARNING!!  Click OK to delete *ALL* settings for %s and force-close the app, losing any current emulation progress.  Are you absolutely sure?

(note: settings for plugins are unaffected) This folder is where PCSX2 records savestates; which are recorded either by using menus/toolbars, or by pressing F1/F3 (save/load). This folder is where PCSX2 saves its logfiles and diagnostic dumps.  Most plugins will also adhere to this folder, however some older plugins may ignore it. This folder is where PCSX2 saves screenshots.  Actual screenshot image format and style may vary depending on the GS plugin being used. This hack works best for games that use the INTC Status register to wait for vsyncs, which includes primarily non-3D RPG titles. Games that do not use this method of vsync will see little or no speedup from this hack. This is the folder where PCSX2 saves your settings, including settings generated by most plugins (some older plugins may not respect this value). This recompiler was unable to reserve contiguous memory required for internal caches.  This error can be caused by low virtual memory resources, such as a small or disabled swapfile, or by another program that is hogging a lot of memory. This slider controls the amount of cycles the VU unit steals from the EmotionEngine.  Higher values increase the number of cycles stolen from the EE for each VU microprogram the game runs. This wizard will help guide you through configuring plugins, memory cards, and BIOS.  It is recommended if this is your first time installing %s that you view the readme and configuration guide. Updates Status Flags only on blocks which will read them, instead of all the time. This is safe most of the time, and Super VU does something similar by default. Vsync eliminates screen tearing but typically has a big performance hit. It usually only applies to fullscreen mode, and may not work with all GS plugins. Warning!  Changing plugins requires a complete shutdown and reset of the PS2 virtual machine. PCSX2 will attempt to save and restore the state, but if the newly selected plugins are incompatible the recovery may fail, and current progress will be lost.

Are you sure you want to apply settings now? Warning!  You are running PCSX2 with command line options that override your configured plugin and/or folder settings.  These command line options will not be reflected in the settings dialog, and will be disabled when you apply settings changes here. Warning!  You are running PCSX2 with command line options that override your configured settings.  These command line options will not be reflected in the Settings dialog, and will be disabled if you apply any changes here. Warning: Some of the configured PS2 recompilers failed to initialize and have been disabled: When checked this folder will automatically reflect the default associated with PCSX2's current usermode setting.  You are about to delete the formatted memory card '%s'. All data on this card will be lost!  Are you absolutely and quite positively sure? You can change the preferred default location for PCSX2 user-level documents here (includes memory cards, screenshots, settings, and savestates).  This option only affects Standard Paths which are set to use the installation default value. You may optionally specify a location for your PCSX2 settings here.  If the location contains existing PCSX2 settings, you will be given the option to import or overwrite them. Your system is too low on virtual resources for PCSX2 to run. This can be caused by having a small or disabled swapfile, or by other programs that are hogging resources. Zoom = 100: Fit the entire image to the window without any cropping.
Above/Below 100: Zoom In/Out
0: Automatic-Zoom-In untill the black-bars are gone (Aspect ratio is kept, some of the image goes out of screen).
  NOTE: Some games draw their own black-bars, which will not be removed with '0'.

Keyboard: CTRL + NUMPAD-PLUS: Zoom-In, CTRL + NUMPAD-MINUS: Zoom-Out, CTRL + NUMPAD-*: Toggle 100/0 Project-Id-Version: PCSX2 0.9.9
Report-Msgid-Bugs-To: https://github.com/PCSX2/pcsx2/issues
POT-Creation-Date: 2016-12-31 11:39+0100
PO-Revision-Date: 2014-08-29 03:56+0900
Last-Translator: nrusef <nrusef@gmail.com>
Language-Team: DeltaHF
Language: ja_JP
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Poedit-KeywordsList: pxE;pxEt
X-Poedit-SourceCharset: utf-8
X-Poedit-Basepath: trunk\
X-Generator: Poedit 1.5.7
X-Poedit-SearchPath-0: pcsx2
X-Poedit-SearchPath-1: common
 [無視]　スレッドの応答を待ちます。
[キャンセル]　スレッドのキャンセルを試行します。
[終了]　PCSX2をただちに終了させます。
 0 - VU サイクルステアリングを無効にします。最も互換性が高いです。 1 - 穏やかな設定です。そこそこ速度が向上しますが、互換性が少し低下します。 2 - 適度な設定です。大きく速度が向上しますが、互換性が低下します。 3 - 最大限の設定です。利用価値は低く、ほとんどのゲームでは画面のちらつき、速度低下などが発生します。 %sを実行するには有効なプラグインを全てについて選択していなければいけません。
プラグインが無かったり、不完全な%sのインストールで、有効な選択ができない場合は
キャンセルを押して設定パネルを閉じてください。 セーブステートをロードした際にメモリーカードデータの再インデックスをゲームに強制する事によって、
メモリーカードデータの破壊を回避します。全てのゲームに互換性があるわけではありません（ギターヒーロー）。 「HDLoader compatibility list」を参照し、この機能を《使用できない》ゲームを調べてください（mode 1/slow DVDと表記されています）。 ウィンドウ内に入ったマウスポインターを自動的に隠します。
主にマウスをコントローラーとして利用している時に便利です。
デフォルトではカーソルが2秒間動かないと自動的に隠れます。 ESCを押すか、エミュレーションを中断した時にGSウィンドウを非表示にする機能です。
ウィンドウが大きいと作業の邪魔になりやすいので、このオプションは便利です。 不具合の発生原因としてMTGSスレッドの同期が疑わしい場合は有効にしてください。 エミュレーション中と再開時に自動でフルスクリーンにする機能を有効にします。[ALT] + [Enter]のショートカットでいつでも切り替える事ができます。 設定フォルダに既存の%s設定が見つかりました。
この設定をインポート、または%sのデフォルト値で上書きしますか？
（または、キャンセルを押して別の設定フォルダーを選択してください） コピーに失敗しました。コピー先のメモリーカード[%s]は使用中です。 コピーに失敗しました。コピーは空のPS2ポートやファイルシステムに対してのみ許可されています。 以下のゲームに役立ちます：
 * ブリーチブレイドバトラーズ
 * グローランサーII、III
 * ウィザードリィ 以下のゲームに役立ちます：
 * デジタルデビルサーガ（ゲーム内ムービーとクラッシュを修正します）
 * SSX（グラフィックとクラッシュを修正します）
 * ガンサバイバー４ バイオハザードヒーローズネバーダイ（グラフィックがおかしくなります） 以下のゲームに役立ちます：
 * マナケミア～学園の錬金術士たち～
 * メタルサーガ
 以下のゲームに役立ちます：
 * テストドライブ アンリミテッド
 * Transformers NTFS圧縮はエクスプローラーのファイルプロパティから手動でいつでも設定変更できます。 NTFS圧縮は内蔵された機能で完全に信頼できる高速な圧縮方法です。
メモリーカードの圧縮に優れています。（このオプションは強くお勧めします） フレームレート制限が無効になっている場合、ターボやスローモーションモードは使用できません。 メモ：PCSX2の実行にリコンパイラーは必須ではありませんが、エミュレーション速度が大幅に向上します。
エラーを解決した後に、上記リストのリコンパイラーを手動で有効化しなおす必要があるかもしれません。 メモ：PS2のハードウェアの仕様により、正確なフレームスキップは不可能です。
有効にすると、ゲームによっては映像に不具合が起きることがあります。 メモ：ほとんどのゲームはデフォルト設定のままで動作します。 メモ：ほとんどのゲームはデフォルト設定のままで動作します。 メモリ不足（多少）：重大なエラーではありません。SuperVUリコンパイラーが
必要とする特定のメモリ領域を確保する事ができなかったので使用不可となりました。
sVU rec は旧式なので、変わりに microVU を使用した方が良いでしょう。 (^-^) PCSX2はPS2仮想マシンに必要なメモリを割り当てる事ができませんでした。 
バックグラウンドタスクを終了させ、メモリを解放してから再試行してください。 PCSX2を実行するには「合法的」に入手したPS2 BIOSが必要です。 
友人やインターネットから入手したものは使用しないでください。 
「あなた自身が所有する」PS2本体からBIOSを吸い出ししてください。 PCSX2を実行するにはPS2のBIOSが必要です。あなた自身が所有する（借り物はダメです）PS2の実機から 
「合法的に」手に入れてください。詳しい方法はFAQやガイドを参照してください。 PS1のディスクはPCSX2でサポートされていません。 
ePSXeやPCSXなどのPS1向けのエミュレーターをお使いください。 これらのフォルダーが作成され、使用中のユーザーアカウントに書き込み権限がある事を確認してください。 
また、PCSX2を管理者権限で再度起動すると、PCSX2が必要なフォルダーを自動的に作成されます。
管理者権限がない場合、ユーザードキュメントモードに切り替える必要があります
（下のボタンをクリック）。 有効なBIOSイメージファイルを選択してください。
選択できない場合はキャンセルを押して設定パネルを閉じてください。 PCSX2がユーザーレベルドキュメントを保存するディレクトリーを指定してください。
（メモリーカード、スクリーンショット、各種設定、セーブステート）
保存場所はそれぞれの設定画面でいつでも変更する事ができます。 カーネルの 0x81FC0 アドレスにあるEEアイドルループを主に監視し、別ユニットのエミュレーションが発動するイベントまで、
全ての反復でマシンステートが同一である保証があるループの探知を試みます。検出ループに対し一度の反復後に次のイベント、
またはプロセッサのタイムスライスの末尾のどちらか近いほうへ飛びます。 MTGSスレッドやGPUのオーバーヘッドにより発生されるベンチマークノイズを除去します。このオプションはセーブステートと併用して利用する事が適切です。
都合のつく所でセーブステートを行い、オプションを有効にした後に、セーブステートをロードしてください。

警告：　このオプションはゲーム実行中に有効化できますが、無効化する事はできません（映像出力内容の判別ができなくなります）。 VU1を独自のスレッドで実行します（microVU1のみ）。一般的に3コア以上のCPUで速度が向上します。
互換性の低下もほぼありませんが、フリーズする可能性があります。 スピードハックはエミュレーション速度を向上させますが、不正確なFPSを表示されたり、不具合や音声の乱れが起きることがあります。
エミュレーションについて問題が発生した時は、まずはこのパネルの設定を無効にしてみてください。 PS2スロット[%d]は自動的に無効にされました。この問題を解決するには
メインメニューから [設定→メモリーカード] で再度有効化してください。 プリセットは各種スピードハック、リコンパイラー設定や速度を向上させるゲームフィックスを適用します。
既知のゲームフィックスは自動的に適用されます。

チェックをはずすと現在のプリセットを基に手動で設定を変更できます。 プリセットは各種スピードハック、リコンパイラー設定や速度を向上させるゲームフィックスを適用します。
既知のゲームフィックスは自動的に適用されます。

プリセットについて：
1 -    最も高精度なエミュレーションですが、最も低速です。
3 --> 速度と互換性のバランス型。
4 -    能動的なハックを付加します。
6 -    ハック数が多すぎてほとんどのゲームでは遅くなります。
 指定されたディレクトリーは存在しません。作成しますか？ %sスレッドの応答がありません。デッドロック状態か、
「非常に低速」で動作している可能性があります。 仮想メモリが不足しているか、必要な仮想メモリは既に他のプロセス、サービス、DLLに割り当てられています。 この操作は既存の仮想マシンをリセットします。
進行中の全ての作業が失われます。本当にリセットしてもよろしいですか？ この操作は%sの設定を全て削除してリセットします。
次回起動時に初期設定ウィザードを再実行させる事ができます。
 この操作を実行した後に手動で%sを再起動する必要があります。

警告： OKをクリックすると%s設定を「全て削除」します。
プログラムは強制終了し、進行中のエミュレーション作業は失われます。
本当によろしいですか？

（注意： プラグインの設定に影響はありません） PCSX2のセーブステートはこのフォルダーに保存されます。
メインメニューのシステムから、または「F1」（セーブ）と「F3」（ロード）の
ショートカットキーでステート操作を行う事ができます。 PCSX2のログやダンプファイルはこのフォルダーに保存されます。
プラグインは通常この設定を利用しますが、古いものはこの限りではありません。 PCSX2のスクリーンショットはこのフォルダーに保存されます。
実際のスクリーンショットのファイル形式とスタイルは使用しているGSプラグインによって変わります。 垂直同期を待つためにINTCステータスレジスタを使用しているゲーム（主に非3D RPG）で使うと効果が得られます。
この手法を使用しないゲームでは、速度向上はわずかです。 このフォルダーにはPCSX2とプラグインが生成した設定が保存されています。
（古いプラグインはこの値を使用しない事があります） リコンパイラーが内部キャッシュ用の連続したメモリを確保する事ができませんでした。このエラーは仮想メモリの
リソースが不足していると発生します。仮想メモリが小さすぎるか、無効にされている場合や、他のプログラムが
多くのメモリを消費している時に発生します。ホスト設定でPCSX2のリコンパイラのデフォルトキャッシュサイズを
小さく設定する事で問題を解決できる事があります。 VUがEEから奪うサイクルを増減させます。値が高いほどVUプログラム数に応じてEEから奪うサイクルが増加します。 このウィザードではプラグイン、メモリーカード、BIOSの初期設定を行います。
%sを初めてインストールした方はReadmeと設定ガイドを始めにお読みください。 ステータスフラグを常に読み込まずに、読み込まれるブロックのみをアップデートします。
ほぼ安全に使う事ができ、Super VUもデフォルトで同じような動作をします。 Vsync（垂直同期）は画面の水平な乱れ（ティアリング）を除去しますが、パフォーマンスに悪影響を及ぼします。
フルスクリーン時に適用され、全てのGSプラグインで動作しないことがあります。 警告：プラグインの変更はPS2仮想マシンの完全なシャットダウンとリセットが必要です。
PCSX2はステートセーブを行い、変更されたプラグインでステートの復帰を試行しますが、
互換性が無かった場合は復帰に失敗し、進行中の作業が失われる可能性があります。

本当に設定を適用してもよろしいですか？ 警告：通常のプラグイン・フォルダー設定を無効化するコマンドラインでPCSX2を実行しています。コマンドラインで変更されたオプションは設定ダイアログに反映されず、ここで設定を変更しても無効化されます。 警告：通常の設定を無効化するコマンドラインでPCSX2を実行しています。コマンドラインで変更されたオプションは設定ダイアログに反映されず、ここで設定を変更しても無効化されます。 警告：設定されたいくつかのPS2リコンパイラーが初期化に失敗し、無効にされました。 チェックを入れるとこのフォルダーは現在のPCSX2のユーザーモード設定に関するデフォルトを自動的に反映されます。 フォーマットされたメモリーカード[%s]を削除しようとしています。
メモリーカードのデータは全て失われます。本当に削除してもよろしいですか？ PCSX2がユーザーレベルドキュメントを保存するディレクトリーを変更する事ができます
（メモリーカード、スクリーンショット、各種設定、セーブステート）。
インストール時のディレクトリを標準ディレクトリとして指定するものにのみ効果があります。 PCSX2の設定を保存するディレクトリーを任意に指定する事ができます。指定先のディレクトリに
PCSX2設定が既にある場合は、インポートまたは上書きをするオプションが表示されます。 PCSX2を実行するための仮想メモリリソースが不足しています。スワップファイルが小さすぎるか
無効にされている場合や、他のプログラムがメモリの多くを消費している時に発生します。 ズーム率が100の場合、映像出力をクロッピング（トリミング）せず、画面に合わせて伸縮します。
100より低い場合はズームイン、高い場合はズームアウトします。0の場合は自動ズームインで黒い枠を消します（アスペクト比を保ちますが、多少外にでる事があります）。
メモ：一部のゲームでは黒枠を描画する事があり、値を0に設定しても消えません。

ショートカットキー： [CTRL] + [＋]でズームイン、[CTRL] + [－]でズームアウト、[CTRL] + [*]でズーム値100/0切り替え（＋－*はテンキーを使用） 