# dotDev

a small collection of dev files

## notes
### Scripts
    # check_tools
        - will feature list of programs to make sure that they're installed. 

### Shell 
    #zsh 
    #zsh-autosuggestions, zsh-syntax-highlighting
    sudo install zsh
#chsh -s $(which zsh)
#mv ~/.zshrc ~/.config
#cd .config
#ls -a
    ln -s ~/.config/.zshrc ~/.zshrc

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sudo apt install fzf
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
### CLI
    fzf, ripgrep, git, 
    - sudo apt install ripgrep
    sudo apt install fd-find
    # ln -s $(which fdfind) ~/.local/bin/fd // sometimes the fdfind needs to be set
    sudo apt install bpytop
    git config --global credential.helper store
### text editor
    nvim
### file manager 
### Terminal multiplexer
    tmux

sudo apt install libevent-dev
sudo apt install bison byacc
sudo apt-get install libncurses5-dev libncursesw5-dev
sudo apt-get install ncurses-bin build-essential
sudo apt install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/.config/.tmux.conf ~/.tmux.conf
### Software
    - node
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash
sudo apt-get install -y nodejs
