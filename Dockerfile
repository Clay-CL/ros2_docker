FROM ubuntu:24.04
# Use bash as the default shell
SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake clang net-tools htop wget curl zip\
    xfce4 xfce4-goodies tightvncserver tigervnc-standalone-server dbus-x11 xfonts-base \
    tmux ranger neofetch curl git fzf\
    python3 python3-dev python-is-python3 python3-pip python3-venv

RUN touch .Xauthority

RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
RUN tar -C /opt -xzf nvim-linux64.tar.gz
RUN rm -rf nvim-linux64.tar.gz
RUN echo "export PATH=$PATH:/opt/nvim-linux64/bin" >> ~/.bashrc
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim
RUN rm -rf ~/.config/nvim/.git

COPY .tmux.conf /root/.tmux.conf

COPY .bashrc /root/.bashrc.tmp
RUN curl -o /usr/share/doc/fzf/examples/key-bindings.bash https://raw.githubusercontent.com/junegunn/fzf/0.20.0/shell/key-bindings.bash
RUN cat /root/.bashrc.tmp >> /root/.bashrc
RUN rm /root/.bashrc.tmp
