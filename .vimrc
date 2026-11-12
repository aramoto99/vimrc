" 基本設定
set encoding=utf-8
scriptencoding utf-8

" Vim 公式推奨: 独自 vimrc でも defaults.vim を読む
" (前回のカーソル位置復元・:DiffOrig 等。以降の設定で上書きされる)
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set fileencoding=utf-8
set fileencodings=utf-8,cp932,euc-jp,iso-2022-jp,sjis  " 日本語ファイルを自動判別
set fileformats=unix,dos,mac                          " 改行コード(LF/CRLF/CR)を自動判別
set helplang=ja,en                                    " :help を日本語優先 (vimdoc-ja があれば)
set iminsert=0                                        " インサートモード開始時はIME OFF
set imsearch=-1                                       " 検索時もIME OFF
set formatoptions+=mMj                                " マルチバイト文字での整形を改善
set linebreak                                         " 単語/文字の途中で折り返さない
set breakindent                                       " 折り返し時もインデントを揃える
set display=lastline                                  " 長い行の最終行を切り捨てず表示
set smoothscroll                                      " 折り返し行も画面行単位でスクロール
set splitkeep=screen                                  " 分割時に本文の表示位置をずらさない
" 全角記号(○●★等)が半角幅になって崩れるときのみ有効化
" Powerlineフォント使用中はレイアウトが崩れる可能性があるため通常はOFF
" set ambiwidth=double
set expandtab
set tabstop=4
set shiftwidth=4
set number
set cursorline
set showcmd
set showmatch
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%
set mouse=a
set ttymouse=sgr              " Windows Terminal/VSCodeで200列以上でもマウスが正常動作 (Vim 9 は自動判定するが保険)
set updatetime=250            " CursorHold(外部変更チェック)・GitGutter 用
set timeoutlen=500            " キーマッピングの待機時間を短縮
set synmaxcol=200             " 200列以上はシンタックスハイライトしない (長い行で重くなるのを防ぐ)
set scrolloff=8               " カーソルを画面端から8行分離す
set signcolumn=yes            " サイン列を常に表示 (GitGutterでレイアウトがずれない)
set splitright                " 縦分割は右に開く
set splitbelow                " 横分割は下に開く
set shortmess-=S              " 検索時に [3/12] のように件数を表示
" タブページが2つ以上のとき、左側に縦のタブ一覧を表示
set showtabpanel=1
set tabpanelopt=columns:20,vert

" 検索設定
set ignorecase
set smartcase
set incsearch
set hlsearch

" コマンドライン自動補完 (Vim 9.2): : / ? を打つと候補がポップアップ
set wildmenu
set wildmode=noselect:lastused,full
set wildoptions=pum,fuzzy
augroup CmdlineAutocomplete
    autocmd!
    autocmd CmdlineChanged [:\/\?] call wildtrigger()
augroup END
" <Up>/<Down> は補完メニュー表示中でもコマンド履歴として使う
cnoremap <expr> <Up>   wildmenumode() ? "\<C-E>\<Up>"   : "\<Up>"
cnoremap <expr> <Down> wildmenumode() ? "\<C-E>\<Down>" : "\<Down>"

" バックアップ / スワップ
" writebackup は既定(ON)のまま: OFF だと書き込み失敗時に元ファイルも失う (:h 'writebackup')
set nobackup
set swapfile
set directory=~/.vim/swap//
silent! call mkdir(expand('~/.vim/swap'), 'p')

" 永続的なUndo (セッションをまたいでCtrl+Zが使える)
set undofile
set undodir=~/.vim/undo//
silent! call mkdir(expand('~/.vim/undo'), 'p')

" True Color (t_8f/t_8b は Vim 9.0.1111 以降自動設定されるため不要)
if has('termguicolors')
    set termguicolors
endif

" 外部変更の自動反映 (Claude Code 等がファイルを書き換えたとき)
" autoread だけではターミナル Vim は変更を検知しないため checktime を定期的に呼ぶ
set autoread
function! s:CheckTime(...) abort
    " q: ウィンドウやコマンドライン入力中は E11 になるので避ける
    if getcmdwintype() ==# '' && mode() !~# '[ct]'
        silent! checktime
    endif
endfunction
augroup AutoReload
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * call s:CheckTime()
    autocmd FileChangedShellPost * echohl WarningMsg
                \ | echomsg '外部で変更されたため再読込: ' . expand('<afile>') | echohl None
augroup END
" 無操作の間も拾う (Claude の作業を眺めているとき)
let s:reload_interval_ms = 1000
if has('timers') && !exists('s:reload_timer')
    let s:reload_timer = timer_start(s:reload_interval_ms, function('s:CheckTime'), {'repeat': -1})
endif

" diff レビュー (indent-heuristic, inline:char は Vim 9.2 の既定で有効)
set diffopt+=linematch:60,algorithm:histogram

" OSC52クリップボード連携
" Vim 同梱の osc52 パッケージ: "+y でクリップボードへコピー (動作確認後、下の自作関数は削除可)
if has('clipboard_provider')
    packadd osc52
    set clipmethod+=osc52
    let g:osc52_disable_paste = 1   " OSC52 ペースト非対応端末で "+p が固まるのを防ぐ
endif

" 自作版 (同梱版が動かない端末向けのフォールバック)
" SSH経由でWindows Terminal/VSCodeのクリップボードに直接コピーできる
function! YankOSC52(text)
    let b64 = system('base64 -w 0', a:text)
    let b64 = substitute(b64, '\n', '', 'g')
    let seq = "\033]52;c;" . b64 . "\007"
    call writefile([seq], '/dev/tty', 'b')
endfunction

function! YankOSC52Visual()
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    if len(lines) == 0 | return | endif
    let lines[-1] = lines[-1][:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    call YankOSC52(join(lines, "\n"))
endfunction

nnoremap <silent> <leader>y :.call YankOSC52(getline('.'))<CR>
vnoremap <silent> <leader>y :<C-u>call YankOSC52Visual()<CR>
nnoremap <silent> <leader>Y :<C-u>call YankOSC52(join(getline(1, '$'), "\n"))<CR>

" Vim 同梱パッケージ
packadd comment      " gcc / gc でコメント切替 (vim-commentary の代替)
packadd hlyank       " ヤンク範囲を一瞬ハイライト

" プラグイン管理
call plug#begin()
Plug 'preservim/nerdtree',         { 'on': 'NERDTreeToggle' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'
" fzf 本体は遅延ロードしない ('on': [] だと fzf#run 未定義で :Files が E117 になる)
Plug 'junegunn/fzf',               { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim',           { 'on': ['Files', 'Rg'] }
Plug 'tpope/vim-fugitive',         { 'on': ['Git', 'Gdiffsplit', 'Gvdiffsplit', 'GBrowse'] }
Plug 'airblade/vim-gitgutter'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'tpope/vim-surround'
call plug#end()

" NERDTree設定 (VSCode風のサイドバー)
nnoremap <C-b> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let g:NERDTreeWinSize=24

" Airline設定
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='onedark'
" Powerlineフォントを使用 (未インストールの場合は下行をコメントアウト)
let g:airline_powerline_fonts = 1
" 使わない拡張を無効化して描画を軽くする
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#hunks#enabled = 0

" VSCode風のキーバインド
" (map 行末に " コメントを書くとコメントが rhs に含まれるため、コメントは前の行に書く)
" ファイル検索
nnoremap <C-p> :Files<CR>
" テキスト検索 (要 ripgrep)
nnoremap <C-f> :Rg<CR>
" 前のバッファ / 次のバッファ
nnoremap <C-j> :bprevious<CR>
nnoremap <C-k> :bnext<CR>
" 保存 (インサートモードからも)
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" 選択行を J / K で上下に移動
xnoremap J :m '>+1<CR>gv=gv
xnoremap K :m '<-2<CR>gv=gv

" Claude Code を右の縦分割ターミナルで起動 (終了時にウィンドウも閉じる)
" ターミナル内で Ctrl-W を Claude に送るときは Ctrl-W . と打つ
command! ClaudeTerm vertical terminal ++close claude

" fzf設定
" Vim 8.2+ / Neovim はポップアップウィンドウ、それ以外は下部パネル
if has('popupwin') || has('nvim')
    let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
else
    let g:fzf_layout = { 'down': '40%' }
endif

" カラースキーム設定
syntax on
let g:onedark_color_overrides = {
\ "background": {"gui": "#1E1E1E", "cterm": "234", "cterm16": "0" },
\}
colorscheme onedark

" 全角スペース(U+3000)を赤く可視化 (日本語入力で混入しがち)
augroup HighlightZenkakuSpace
    autocmd!
    autocmd ColorScheme * highlight ZenkakuSpace cterm=underline ctermfg=red guibg=#cc0000
    autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
augroup END
highlight ZenkakuSpace cterm=underline ctermfg=red guibg=#cc0000
match ZenkakuSpace /　/

" インデントガイド: shiftwidth ごとに ┊ を表示 (ftplugin で shiftwidth が変わっても追従)
let s:indent_guide_char = '┊'
function! s:UpdateIndentGuide() abort
    let &l:listchars = &g:listchars . ',leadmultispace:' . s:indent_guide_char . repeat(' ', shiftwidth() - 1)
endfunction
augroup IndentGuide
    autocmd!
    autocmd OptionSet shiftwidth,tabstop call s:UpdateIndentGuide()
    autocmd BufWinEnter * call s:UpdateIndentGuide()
augroup END

" Git設定
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" ESCキー2回押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" 保存時に末尾の空白を自動削除
" カーソル位置・検索履歴を保ち、行末2スペースが意味を持つ Markdown と diff/patch は除外
let s:trim_exclude_filetypes = ['markdown', 'diff', 'gitcommit']
function! s:TrimTrailingWhitespace() abort
    if index(s:trim_exclude_filetypes, &filetype) >= 0 || &binary
        return
    endif
    let l:view = winsaveview()
    keeppatterns silent! %s/\s\+$//e
    call winrestview(l:view)
endfunction
augroup TrimWhitespace
    autocmd!
    autocmd BufWritePre * call s:TrimTrailingWhitespace()
augroup END

" ヘルプ表示用の関数
function! ShowVimHelp()
   echo "=== Vim ショートカット一覧 ==="
   echo "\nファイル操作:"
   echo "  Ctrl+b : ファイルツリーの表示/非表示"
   echo "  Ctrl+p : ファイル検索"
   echo "  Ctrl+f : テキスト検索 (要 ripgrep)"
   echo "  Ctrl+j : 前のバッファ"
   echo "  Ctrl+k : 次のバッファ"
   echo "\n編集:"
   echo "  gcc   : 現在行をコメント/アンコメント"
   echo "  gc    : 選択範囲をコメント/アンコメント (ビジュアルモード)"
   echo "  J / K : 選択行を下/上に移動 (ビジュアルモード)"
   echo "\n囲み文字 (vim-surround):"
   echo "  cs\"'  : ダブルクォートをシングルクォートに変更"
   echo "  ds\"   : ダブルクォートを削除"
   echo "  ysiw) : 単語を括弧で囲む"
   echo "\nGit操作:"
   echo "  ]h / [h          : 次/前の変更箇所へ"
   echo "  leader+hp/hs/hu  : 変更箇所のプレビュー/ステージ/取り消し"
   echo "  :Git → = / - / X : インライン diff / ステージ / 破棄"
   echo "  :Gdiffsplit      : index との差分を左右に表示"
   echo "\nClaude Code:"
   echo "  :ClaudeTerm : 右の分割で claude を起動"
   echo "  Ctrl-W .    : ターミナル内で Ctrl-W を送る"
   echo "  Ctrl-W N    : ターミナル出力をスクロール (i で戻る)"
   echo "  外部で変更されたファイルは自動で再読込されます (u で戻せる)"
   echo "\nクリップボード (OSC52 / SSH経由):"
   echo "  \"+y      : 同梱 osc52 でコピー"
   echo "  leader+y : 現在行/選択範囲をコピー (自作版)"
   echo "  leader+Y : ファイル全体をコピー (自作版)"
   echo "\nその他:"
   echo "  Ctrl+s  : 保存"
   echo "  Esc+Esc : 検索ハイライトの切り替え"
   echo "\n日本語サポート:"
   echo "  全角スペース(　)は赤く可視化されます"
   echo "  cp932/euc-jp/iso-2022-jp のファイルは自動判別で開けます"
   echo "  :help は日本語優先 (vimdoc-ja インストール時)"
endfunction

" :Helpで表示
command! Help call ShowVimHelp()
