
git clone git@github.com:dkarter/dotfiles.git
ln -s ~/oss/dotfiles/config/nvim ~/.config/nvim
mv ~/.vimrc ~/.vimrc.old
mv ~/.vimrc.local ~/.vimrc.local.old
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
# installed Hack Font -- big repo, takes a second
git clone --depth=1 https://github.com/ryanoasis/nerd-fonts.git
cd nerd-fonts
./install Hack
# uninstall 
