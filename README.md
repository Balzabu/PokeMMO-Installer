# PokeMMO Bash Installer

Set up [PokeMMO](https://pokemmo.com) on Ubuntu, without using _snap_ cause we **hate** proprietary software!
</br>
Intended for personal use, made as an excercise.

**Officially support Debian based distributions**.

## Requirements
The script doesn't really have "requirements", most of the tools should come preinstalled in most Linux distros.
</br>
Here some of the utilities you might need in case you see some strange errors: _wget, unzip_ and _zenity_.

Please note the script **will not install Java SDK**, you can choose which version you prefer before or after installing the game ( **Quick-fix**: sudo apt install default-jdk ) .

## Usage
Execute the following one-liner or download and run the script, then follow the prompts.

> **Bash one-liner**: &nbsp;&nbsp;  _wget -O - https://raw.githubusercontent.com/Balzabu/PokeMMO-Installer/main/PokeMMO-Installer.sh | bash <(cat) </dev/tty_


Once you execute the Installer you will be asked on which folder you want to install the game.
</br>The Installer will try to default to _$HOME/.PokeMMO_; in case you want to use a Custom Path simply **create it before executing the Installer**.
</br>
After the game .ZIP has been downloaded and extracted, the script will then create two Desktop Entries:

<ul>
    <li> One to run the game.</li>
    <li> One to uninstall the game.</li>
</ul>

You can also uninstall the game through the command _uninstall_pokemmo_ that gets added to your _$HOME/.local/bin_ folder.
Once the game is uninstalled all the Desktop Entries and scripts will be removed, leaving the system fully clean.

## Official Version
There's also another version here on GitHub made by one of the official developers of PokeMMO, [@coringao](https://github.com/coringao/): [PokeMMO Installer for GNU/Linux](https://github.com/coringao/pokemmo-installer).
It's pretty old but should still work fine, so in case of any problems check his project!
