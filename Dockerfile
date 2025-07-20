FROM osrf/ros:jazzy-desktop-full
# Use bash as the default shell
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y sudo

# Create user with sudo privileges - use host user ID to avoid permission issues
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=ubuntu
ENV USER_NAME=${USER_NAME}

RUN getent group ${GROUP_ID} || groupadd -g ${GROUP_ID} ${USER_NAME}; \
    if id -u ${USER_ID} >/dev/null 2>&1; then \
        usermod -l ${USER_NAME} -d /home/${USER_NAME} -m $(getent passwd ${USER_ID} | cut -d: -f1) && \
        groupmod -n ${USER_NAME} $(getent group ${GROUP_ID} | cut -d: -f1); \
    else \
        useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash ${USER_NAME}; \
    fi && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME}:${USER_NAME}" | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    touch /home/${USER_NAME}/.sudo_as_admin_successful

RUN apt-get install -y --no-install-recommends \
    build-essential cmake clang\
    tmux ranger neovim neofetch git fzf net-tools htop wget curl zip unzip tar\
    python3 python3-dev python-is-python3 python3-pip python3-venv lsb-release \
 && rm -rf /var/lib/apt/lists/*

RUN chmod 777 /opt

RUN curl -o /usr/share/doc/fzf/examples/key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/0.20.0/shell/key-bindings.bash

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

RUN tee ~/.gitconfig > /dev/null <<'EOF'
[alias]
	tree = log --all --decorate --oneline --graph
[core]
	editor = nvim
EOF

RUN tee ~/.tmux.conf > /dev/null <<'EOF'
unbind C-b
set -g prefix C-a
bind-key C-a last-window

setw -g mode-keys vi

# Set new panes to open in current directory
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"

set -g status-left-length 20

set-option -g history-limit 10000

setw -g mouse on

set-window-option -g xterm-keys on
set -g default-terminal "screen-256color"
EOF

RUN tee -a ~/.bashrc > /dev/null <<'EOF'
alias t='tmux'
alias v='nvim'
alias r='ranger'
alias p='python3'

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='[${PWD/*\//}]$(git_branch)>>'
PS1="\[\e[0;34m\]$PS1\[\e[m\]"
export PS1

set -o vi
bind -m vi-insert "\C-l":clear-screen

source /usr/share/doc/fzf/examples/key-bindings.bash
EOF

RUN mkdir -p ~/.config/nvim
RUN tee ~/.config/nvim/init.vim > /dev/null <<'EOF'
" =============================
" BASIC SETTINGS
" =============================
set nocompatible          " Disable Vi compatibility
set number                " Show line numbers
set relativenumber        " Show relative line numbers
set showcmd               " Show command in the last line
set cursorline            " Highlight current line
set ruler                 " Show cursor position
set wildmenu              " Tab-completion menu in commands
set clipboard=unnamedplus " Use system clipboard

" =============================
" INDENTATION & FORMATTING
" =============================
set tabstop=4             " 4 spaces per tab
set shiftwidth=4          " 4 spaces for indentation
set expandtab             " Use spaces instead of tabs
set autoindent            " Auto-indent new lines
set smartindent           " Smarter auto-indenting
set nowrap                " Don't wrap long lines
set formatoptions+=cro    " Better comment formatting

" =============================
" SEARCH
" =============================
set ignorecase            " Case-insensitive search
set smartcase             " But case-sensitive if uppercase used
set incsearch             " Show search matches as you type
set hlsearch              " Highlight all search results
nnoremap <leader><space> :nohlsearch<CR>  " Clear highlights

" =============================
" FILE MANAGEMENT
" =============================
set backup                " Enable backups
set backupdir=~/.vim/backup//
set undofile              " Persistent undo
set undodir=~/.vim/undo//
set swapfile              " Enable swap files
set directory=~/.vim/swap//

" =============================
" MAPPINGS
" =============================
let mapleader=" "         " Set leader key to space

" Quick Save
nnoremap <leader>w :w<CR>

" Toggle Line Numbers
nnoremap <leader>n :set number! relativenumber!<CR>

" =============================
" FOLDING
" =============================
set foldmethod=syntax     " Fold based on syntax
set foldlevel=99          " Open all folds by default
nnoremap <space> za       " Toggle fold with spacebar

" =============================
" BETTER NAVIGATION
" =============================
" Move by display lines when lines are wrapped
nnoremap j gj
nnoremap k gk

" =============================
" VISUAL ENHANCEMENTS
" =============================
syntax on                 " Enable syntax highlighting
set background=dark       " Suitable for dark themes
colorscheme desert        " Built-in colorscheme (you can try others like 'elflord', 'evening', 'murphy')
EOF
