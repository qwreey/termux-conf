#!/usr/bin/sh

# Update system first
pkg update ; apt full-upgrade -y

# Update base packages and install packages
if ! apt list --installed 2>/dev/null | grep fish; then
	apt install -y vim fish git curl openssh zip unzip android-tools
else
	echo "Fish shell already installed"
fi

# Init ssh
if ! [ -e ~/.ssh/id_ed25519.pub ]; then
	ssh-keygen -A
	echo -n "Enter ssh key name: "
	read -r ssh_keyname
	ssh-keygen -t ed25519 -C "$ssh_keyname" -N "" -f ~/.ssh/id_ed25519
	echo -n "Your ssh key: "
	cat ~/.ssh/id_ed25519.pub
fi

# Update git config
git config --global credential.helper store
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
if ! grep "email = " ~/.gitconfig &> /dev/null; then
	echo -n "Enter git user email: "
	read -r git_user_email
	git config --global user.email "$git_user_email"
fi
if ! grep "name = " ~/.gitconfig &> /dev/null; then
	echo -n "Enter git user name: "
	read -r git_user_name
	git config --global user.name  "$git_user_name"
fi

# Install fish shell
if ! [ -e ~/.config/fish/functions/qwreey-fish ]; then
	fish -c "curl -sL 'https://raw.githubusercontent.com/qwreey/qwreey-fish/refs/heads/main/functions/qs_setup.fish' | source && qs_setup" < /dev/null \
	|| echo "user-init: qs_setup exited non-zero (see comment above) - continuing anyway" >&2
fi

# Remove moted
: > $PREFIX/etc/motd

# Change shell to fish
chsh -s fish

# Init .termux
mkdir -p ~/.termux
cat << EOF > ~/.termux/termux.properties
extra-keys = [ [{key: 'ESC', popup: 'KEYBOARD'},{key: '$', popup: '|'},{key: '/', popup: 'BACKSLASH'}, {key: '~', popup: '='},{key: '[', popup: ']'},{key: '(', popup: ')'},{key: 'UP', popup: 'PGUP'},{key: 'TAB', popup: 'DRAWER'}], [{key: 'CTRL', popup: 'ALT'},{key: ';', popup: ':'},{key: '\\\\'', popup:'"'},{key: '-', popup: '_'},{key: '{', popup: '}'},{key: 'LEFT', popup: 'HOME'},{key: 'DOWN', popup: 'PGDN'},{key: 'RIGHT', popup: 'END'}] ]
bell-character=ignore
enforce-char-based-input=true
EOF
cat << EOF > ~/.termux/colors.properties
background: #282A36
foreground: #F8F8F2
color0:     #000000
color8:     #4D4D4D
color1:     #FF5555
color9:     #FF6E67
color2:     #50FA7B
color10:    #5AF78E
color3:     #F1FA8C
color11:    #F4F99D
color4:     #BD93F9
color12:    #CAA9FA
color5:     #FF79C6
color13:    #FF92D0
color6:     #8BE9FD
color14:    #9AEDFE
color7:     #BFBFBF
color15:    #E6E6E6
EOF

# Init fonts
if ! [ -e ~/.termux/font.ttf ]; then
	mkdir -p .downloads
	curl -Lo .downloads/jetendard-ttf.zip https://github.com/kuskhan/jetendard/releases/download/v0.1.0/Jetendard-TTF.zip
	unzip .downloads/jetendard-ttf.zip -d .downloads/jetendard-ttf
	cp .downloads/jetendard-ttf/ttf/Jetendard-Regular.ttf ~/.termux/font.ttf
fi

# Reload termux config and setup storage
termux-reload-settings
if ! [ -e ~/storage ]; then
	termux-setup-storage
fi

