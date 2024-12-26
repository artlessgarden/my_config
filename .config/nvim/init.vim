set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set autoindent
set smartindent
"set number
"set relativenumber
set updatetime=1000
autocmd CursorHold,CursorHoldI * silent! update
autocmd FocusLost * silent! update
autocmd BufLeave,WinLeave * silent! update
autocmd BufEnter * silent! update
autocmd InsertLeave * silent! update

call plug#begin()
Plug 'junegunn/fzf.vim'
Plug 'vimwiki/vimwiki'
Plug 'michal-h21/vim-zettel'
Plug 'morhetz/gruvbox'
"Plug 'easymotion/vim-easymotion'
"Plug 'stevearc/oil.nvim'
"Plug 'nvim-tree/nvim-tree.lua'
"Plug 'nvim-tree/nvim-web-devicons'
Plug 'ggandor/leap.nvim'
Plug 'axieax/urlview.nvim'

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'
" For ultisnips users.
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'
" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'

call plug#end()

let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'medium'
colorscheme gruvbox
set background=dark

let mapleader = " "
nnoremap <leader>fs :cd ~/<CR>:Rg<CR>
nnoremap <leader>ff :Files ~/<CR>
let g:nv_search_paths = ['~/garden']
nnoremap <leader>fm :!mkdir -p "%:h"<CR>

let g:vimwiki_conceallevel=0

function! OpenSelection()
  execute '!xdg-open ' . shellescape(@")
endfunction
vnoremap <Leader>o :<C-u>call OpenSelection()<CR>

lua << EOF

local function open_attachment()
    local attachment = vim.fn.expand("%:p"):gsub("%.md$", "") -- 去掉 .md 后缀
    if vim.fn.filereadable(attachment) == 1 then
        vim.fn.jobstart({"xdg-open", attachment})
    end
end
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*.md",
    callback = open_attachment,
})
vim.api.nvim_create_user_command("OpenAttachment", open_attachment, {})
vim.keymap.set("n", "<leader>k", ":OpenAttachment<CR>", { noremap = true, silent = true })



vim.keymap.set('n',        's', '<Plug>(leap)')
vim.keymap.set('n',        'S', '<Plug>(leap-from-window)')
vim.keymap.set({'x', 'o'}, 's', '<Plug>(leap-forward)')
vim.keymap.set({'x', 'o'}, 'S', '<Plug>(leap-backward)')



-- 获取当前文件前缀
local function get_prefix(filename)
  return filename:match("^(%d+%.%d+)_")
end

-- 获取当前文件名
local function get_current_filename()
  return vim.fn.expand("%:t") -- 当前文件名
end

-- 查找匹配前缀的文件
local function find_file_by_prefix(prefix)
  local files = vim.fn.readdir(vim.fn.expand("%:p:h")) -- 当前文件夹的文件列表
  for _, file in ipairs(files) do
    if file:match("^" .. prefix .. "_") then
      return file
    end
  end
  return nil -- 未找到
end

-- 打开文件
local function open_file(filename)
  if filename then
    vim.cmd("edit " .. filename)
  else
    vim.notify("文件未找到", vim.log.levels.ERROR)
  end
end

-- 切换到父级文件
local function open_parent_file()
  local current_file = get_current_filename()
  local prefix = get_prefix(current_file)
  if prefix then
    local parent_prefix = prefix:sub(1, -2) -- 去掉最后一位
    local parent_file = find_file_by_prefix(parent_prefix)
    open_file(parent_file)
  end
end

-- 切换到邻近文件
local function open_adjacent_file(offset)
  local current_file = get_current_filename()
  local prefix = get_prefix(current_file)
  if prefix then
    local major, minor = prefix:match("^(%d+)%.(%d+)$")
    if major and minor then
      local adjacent_prefix = string.format("%s.%d", major, tonumber(minor) + offset)
      local adjacent_file = find_file_by_prefix(adjacent_prefix)
      open_file(adjacent_file)
    end
  end
end

-- 切换到子级文件
local function open_child_file(child_index)
  local current_file = get_current_filename()
  local prefix = get_prefix(current_file)
  if prefix then
    local child_prefix = prefix .. child_index
    local child_file = find_file_by_prefix(child_prefix)
    open_file(child_file)
  end
end

-- 绑定快捷键
vim.keymap.set("n", "<leader>h", open_parent_file, { desc = "切换到父级文件" })
vim.keymap.set("n", "<leader>j", function() open_adjacent_file(1) end, { desc = "切换到下一个文件" })
vim.keymap.set("n", "<leader>k", function() open_adjacent_file(-1) end, { desc = "切换到上一个文件" })

-- 子级文件绑定到 <leader>k1, <leader>k2 等
for i = 1, 9 do
  vim.keymap.set("n", "<leader>l" .. i, function()
    open_child_file(tostring(i))
  end, { desc = "切换到子级文件 " .. i })
end






  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]]-- 

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
    capabilities = capabilities
  }
EOF
