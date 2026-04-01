" 基本設定
set encoding=utf-8
set fileencoding=utf-8
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
set ttymouse=sgr              " Windows Terminal/VSCodeで200列以上でもマウスが正常動作
set lazyredraw               " マクロ実行中の再描画を抑制
set updatetime=100           " GitGutter推奨値
set timeoutlen=500           " キーマッピングの待機時間を短縮
set scrolloff=8              " カーソルを画面端から8行分離す
set signcolumn=yes           " サイン列を常に表示 (GitGutterでレイアウトがずれない)
set splitright               " 縦分割は右に開く
set splitbelow               " 横分割は下に開く
set wildmenu                 " コマンドライン補完をメニュー表示
set wildmode=longest:full,full

" 検索設定
set ignorecase
set smartcase
set incsearch
set hlsearch

" バックアップファイル無効化
set nobackup
set nowritebackup
set noswapfile

" 永続的なUndo (セッションをまたいでCtrl+Zが使える)
set undofile
set undodir=~/.vim/undo//
silent! call mkdir(expand('~/.vim/undo'), 'p')

" True Color設定 (SSH経由でWindows Terminal/VSCodeに正確な色を送信)
if has('termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" OSC52クリップボード連携
" xclipの代わりにOSC52エスケープシーケンスを使用
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

" プラグイン管理
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'tpope/vim-commentary'
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

" VSCode風のキーバインド
nnoremap <C-p> :Files<CR>           " ファイル検索
nnoremap <C-f> :Rg<CR>              " テキスト検索
nnoremap <C-j> :bprevious<CR>       " 前のタブ
nnoremap <C-k> :bnext<CR>           " 次のタブ
nnoremap <C-s> :w<CR>               " 保存
inoremap <C-s> <Esc>:w<CR>a         " インサートモードからも保存

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

" Git設定
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" ESCキー2回押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" 保存時に末尾の空白を自動削除
autocmd BufWritePre * :%s/\s\+$//e

" ヘルプ表示用の関数
function! ShowVimHelp()
   echo "=== Vim ショートカット一覧 ==="
   echo "\nファイル操作:"
   echo "  Ctrl+b : ファイルツリーの表示/非表示"
   echo "  Ctrl+p : ファイル検索"
   echo "  Ctrl+f : テキスト検索"
   echo "  Ctrl+j : 前のタブ"
   echo "  Ctrl+k : 次のタブ"
   echo "\nコメント (vim-commentary):"
   echo "  gcc   : 現在行をコメント/アンコメント"
   echo "  gc    : 選択範囲をコメント/アンコメント (ビジュアルモード)"
   echo "\n囲み文字 (vim-surround):"
   echo "  cs\"'  : ダブルクォートをシングルクォートに変更"
   echo "  ds\"   : ダブルクォートを削除"
   echo "  ysiw) : 単語を括弧で囲む"
   echo "\nGit操作:"
   echo "  ]h : 次の変更箇所へ"
   echo "  [h : 前の変更箇所へ"
   echo "\nクリップボード (OSC52 / SSH経由):"
   echo "  leader+y : 現在行をコピー"
   echo "  leader+y : 選択範囲をコピー (ビジュアルモード)"
   echo "  leader+Y : ファイル全体をコピー"
   echo "\nその他:"
   echo "  Ctrl+s  : 保存"
   echo "  Esc+Esc : 検索ハイライトの切り替え"
endfunction

" :Helpで表示
command! Help call ShowVimHelp()
