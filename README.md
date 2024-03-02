# dotDev

a small collection of dev files

# setting up helper notes for future
1. download your emulator
2. download nvim - text editor note it should be >nvim. 0.9 - universal linux download instructions
	2.1 - run from home
		2.a curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage
		2.b 
		# Optional: exposing nvim globally.
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

3. download shell
	Ubuntu
	3.1 sudo apt update
	3.2 sudo apt upgrade
	3.3 sudo install zsh
	3.4 chsh -s $(which zsh)
	3.5 Link zshrc file to configs
		3.a mv ~/.zshrc ~/.config
		3.b cd .config
		3.c ls -a
		3.d ln -s ~/.config/.zshrc ~/.zshrc
	3.6 from the home directory download omgmyZsh
		3.a sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
		3.b git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		3.c git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	
4. Install nerd font 
    1. windows is the easiest - install then right click to install - then set it on the terminal 
    2. other terminal emulators?
5. Node
    1. curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash
    2. sudo apt-get install -y nodejs
