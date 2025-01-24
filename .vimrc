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
set clipboard=unnamedplus     " クリップボード連携
set lazyredraw               " マクロ実行中の再描画を抑制
set ttyfast                  " 高速ターミナル接続
set updatetime=300           " より速いレスポンス
set timeoutlen=500           " キーマッピングの待機時間を短縮

" 検索設定
set ignorecase
set smartcase
set incsearch
set hlsearch

" バックアップファイル無効化
set nobackup
set nowritebackup
set noswapfile

" プラグイン管理
call plug#begin()
" 必須プラグイン
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'joshdick/onedark.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
call plug#end()

" NERDTree設定 (VSCode風のサイドバー)
nnoremap <C-b> :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1
let g:NERDTreeWinSize=24

" Airline設定
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_theme='onedark'
let g:airline_powerline_fonts = 1

" VSCode風のキーバインド
nnoremap <C-p> :Files<CR>           " ファイル検索
nnoremap <C-f> :Rg<CR>              " テキスト検索
nnoremap <C-j> :bprevious<CR>       " 前のタブ
nnoremap <C-k> :bnext<CR>           " 次のタブ

" fzf設定
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }

" CoC設定
let g:coc_global_extensions = [
 \ 'coc-json',
 \ 'coc-tsserver',
 \ 'coc-pyright',
 \ 'coc-prettier'
 \ ]

" CoC キーバインド（VSCode互換）
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>f <Plug>(coc-format)
nmap <leader>a <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

" カラースキーム設定
syntax on
set termguicolors
let g:onedark_color_overrides = {
\ "background": {"gui": "#1E1E1E", "cterm": "234", "cterm16": "0" },
\}
colorscheme onedark

" Git設定
set updatetime=100
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" ESCキー2回押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" ヘルプ表示用の関数
function! ShowVimHelp()
   echo "=== Vim ショートカット一覧 ==="
   echo "\nファイル操作:"
   echo "  Ctrl+b : ファイルツリーの表示/非表示"
   echo "  Ctrl+p : ファイル検索"
   echo "  Ctrl+f : テキスト検索"
   echo "  Ctrl+j : 前のタブ"
   echo "  Ctrl+k : 次のタブ"
   echo "\n編集機能:"
   echo "  gd : 定義へ移動"
   echo "  gr : 参照を検索"
   echo "  gi : 実装へ移動"
   echo "  leader+rn : シンボルの名前を変更"
   echo "  leader+f : コードのフォーマット"
   echo "  leader+a : コードアクション"
   echo "  leader+qf : クイックフィックス"
   echo "\nGit操作:"
   echo "  ]h : 次の変更箇所へ"
   echo "  [h : 前の変更箇所へ"
   echo "\nその他:"
   echo "  Esc+Esc : 検索ハイライトの切り替え"
endfunction

" :Helpで表示
command! Help call ShowVimHelp()
