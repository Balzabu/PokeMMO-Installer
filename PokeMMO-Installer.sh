#!/bin/bash
#===================================================================
# HEADER
#===================================================================
#  DESCRIPTION
#     Automatically install PokeMMO easily on Ubuntu without using
#     snap (Canonical stinks).
#===================================================================
#  IMPLEMENTATION
#     Author          Balzabu
#     Copyright       Copyright (c) https://www.balzabu.io
#     License         GNU GPLv3 
#     Github          https://github.com/balzabu
#===================================================================
# END_OF_HEADER
#===================================================================


# PokeMMO Official Download Link 
# This could be expanded with the other mirros, but I've experienced
# no outages on their domains, so I'm sticking to just one.
pokemmo_download="https://dl.pokemmo.com/PokeMMO-Client.zip"


# Initialize variables
installation_path_choice=""
installation_path=""
current_folder_files=""
current_home_path=$(echo $HOME)
default_home_path="$current_home_path"/.PokeMMO/
desktop_file_path="${current_home_path}/.local/share/applications"
uninstaller_file_path="${current_home_path}/.local/bin"


# Useful ANSI codes 
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
WHITE="\e[97m"
ENDCOLOR="\e[0m"


# ==================================================================
# Credits
# ==================================================================
echo -e "\n.-------------------------."
echo -e "| ${RED}Poke${WHITE}MMO${ENDCOLOR} ${YELLOW}Linux ${WHITE}Installer${ENDCOLOR} |"
echo -e "| Made with ${RED}<3${ENDCOLOR} by ${GREEN}Balzabu${ENDCOLOR} |"
echo -e "'-------------------------'\n"


# ==================================================================
# Check if the user wants to specify a custom Installation Path,
# else defaults to: $HOME/.PokeMMO/
# If the user specifies a path before using it checks:
#  1) If the directory exists
#  2) If the directory is writable
# If any of these checks fails, throw an error message and
# ask for input again.
# ==================================================================
installation_choice_valid="False"

while [ "$installation_choice_valid" == "False" ]
do
    # Choice
    echo -e "${YELLOW}{INFO}${ENDCOLOR} Default Installation Path: $default_home_path"
    echo -n "Modify? [y/n]  "
    read installation_path_choice
    echo -ne '\n'

     # If installation_path_choice is unset or null, set default option: n.
    installation_path_choice=${installation_path_choice:-n}

    # User answered "y", "Y"
    if [[ ( "$installation_path_choice" == "y" || "$installation_path_choice" == "Y" ) ]]; then
        installation_choice_valid="True"
        is_path_valid="False"
        while [ "$is_path_valid" == "False" ]
        do
            read -p "Custom Installation Path: " installation_path

            # Does the directory exist?
            if [ -d "$installation_path" ]; then
                # Is the directory writable?
                if [ -w "$installation_path" ]; then
                    is_path_valid="True"
                else
                    echo -e "\n${RED}{ERROR}${ENDCOLOR} Directory isn't writable, please specify another.\n"
                fi
            else
                echo -e "\n${RED}{ERROR}${ENDCOLOR} Directory doesn't exist, please try creating it and retry.\n"
            fi
        done

        # Add a trailing slash if missing
        installation_path=$(sed 's![^/]$!&/!' <<< $installation_path)

        # Override default value, so we can use it later
        default_home_path=$installation_path 

        echo -e "\n${YELLOW}{INFO}${ENDCOLOR} Selected Installation Path: $installation_path\n"

    # User answered "n" or "N"
    elif [[ ( "$installation_path_choice" == "n" || "$installation_path_choice" == "N" ) ]]; then
        installation_choice_valid="True"
        echo -e "${YELLOW}{INFO}${ENDCOLOR} Selected Installation Path: $default_home_path"
    # User answered with a non-accepted value.
    else
        echo -e "${RED}{ERROR}${ENDCOLOR} Option not valid, please try again.\n"
    fi
done


# ==================================================================
# Create Installation Path directory if it doesn't exist.
# Check if the folder contain any kind of files, if it does ask the 
# user if he wants to delete its content or abort execution.
# Note that the directory will be created ONLY when it resides in
# $HOME/.PokeMMO, in all the other cases it should be created beforehand
# ==================================================================
if [ ! -d "$default_home_path" ]; then
    mkdir -p $default_home_path
    echo -e "${YELLOW}{INFO}${ENDCOLOR} Finished creating Installation Path directory."
else
    current_folder_files=$(ls ${default_home_path} | wc -l)
    if [ $current_folder_files -gt 0 ]; then
        echo -e "${YELLOW}{INFO}${ENDCOLOR} The Installation Path already contains files."
        echo -e "${YELLOW}{INFO}${ENDCOLOR} The files in ${WHITE}$default_home_path${ENDCOLOR} will be ${RED}DELETED${ENDCOLOR} in 10 second.\nAbort execution with CTRL+C."
        sleep 10
        rm -rf ${default_home_path}*
        echo -e "${YELLOW}{INFO}${ENDCOLOR} Files deleted."
    else
        echo -e "${YELLOW}{INFO}${ENDCOLOR} Folder is clear."        
    fi
fi


# ==================================================================
# Download the latest ZIP availabe from the official website,
# suppress wget informations with -q option and only show the 
# progress bar.
# ==================================================================
echo -e "\n${YELLOW}{INFO}${ENDCOLOR} Downloading file from ${WHITE}$pokemmo_download${ENDCOLOR}\n"

wget --show-progress -q $pokemmo_download -O ${default_home_path}PokeMMO-Client.zip

echo -e "\n${YELLOW}{INFO}${ENDCOLOR} Finished download \n"

# ==================================================================
# Extract the ZIP, -qq is used to suppress all the messages coming 
# from "unzip".
# In case of errors, they will be showed the same, allowing you to
# identify related issues easily.
# ==================================================================
echo -e "${YELLOW}{INFO}${ENDCOLOR} Extracting the files \n"

unzip -qq ${default_home_path}PokeMMO-Client.zip -d $default_home_path

echo -e "${YELLOW}{INFO}${ENDCOLOR} Finished extraction \n"

# ==================================================================
# Delete the ZIP as no longer required
# ==================================================================
rm -rf ${default_home_path}PokeMMO-Client.zip

# ==================================================================
# PokeMMO already provides a script to run the game, the file is 
# called "PokeMMO.sh".
# As stated inside the file, we must "cd" inside the folder before
# executing the "java" command.
# Instead of editing the original script, it's better to create a new
# one; we will bind it only to our Desktop Entry.
# Note that this is general preference, so you could potentially
# just uncomment the 13th line of their script and use it instead.
# Edit this part accordingly to your preferences, if needed.
# ==================================================================
echo -e "#!/bin/sh
cd $default_home_path
sh ./PokeMMO.sh" > ${default_home_path}PokeMMO_desktop.sh
chmod a+x ${default_home_path}PokeMMO_desktop.sh



# ==================================================================
# Check if the directory ~/.local/share/applications does exist,
# else create it.
# We will store the .desktop file in it so the game can be executed
# only by the current user.  
# ==================================================================

if [ ! -d "$desktop_file_path" ]; then
    echo -e "${YELLOW}{INFO}${ENDCOLOR} Directory ~/.local/share/applications doesn't exists, creating one... ${ENDCOLOR}\n"
    mkdir -p $desktop_file_path
else
    echo -e "${YELLOW}{INFO}${ENDCOLOR} Directory ~/.local/share/applications exists ${ENDCOLOR}\n"
fi



# ==================================================================
# Create a .desktop file to run the game inside 
# ~/.local/share/applications
# https://wiki.archlinux.org/title/desktop_entries
# ==================================================================
echo -e "[Desktop Entry]
Encoding=UTF-8
Categories=Game
Type=Application
Terminal=false
Exec=${default_home_path}PokeMMO_desktop.sh
Name=PokeMMO
Icon=${default_home_path}data/icons/128x128.png" > ${desktop_file_path}/PokeMMO.desktop

echo -e "${YELLOW}{INFO}${ENDCOLOR} Created the Game .desktop file! \n"

# ==================================================================
# Create an uninstaller and add it to the local binaries.
# This will gather the Installation Path used from the .desktop file 
# created during the installation.
# In order to be sure this will work, be sure to not change the
# file name of the .desktop files.
# A .desktop entry for this script will be created too.
# ==================================================================
cat << 'EOT' > ${uninstaller_file_path}/uninstall_pokemmo
current_home_path=$(echo $HOME)
desktop_file_path=${current_home_path}/.local/share/applications
desktop_exec_value=$(sed -n 's/^Exec=\(.*\)/\1/p' < ${desktop_file_path}/PokeMMO.desktop)
desktop_exec_path=$(echo "${desktop_exec_value%/*}/")


if zenity --question --title='Uninstaller PokeMMO' --text='Want to uninstall PokeMMO?' --no-wrap
then
    rm -rf ${desktop_exec_path}
    rm -rf ${desktop_file_path}/PokeMMO.desktop
    rm -rf ${desktop_file_path}/Uninstall-PokeMMO.desktop
    zenity --info --title='Uninstaller PokeMMO' --text='Game and Desktop Entry deleted.' --no-wrap
    shred -u "${0}"
else
    zenity --info --title='Uninstaller PokeMMO' --text='Aborted.' --no-wrap
fi
EOT
chmod a+x ${uninstaller_file_path}/uninstall_pokemmo

# ==================================================================
# Create a .desktop file shortcut to uninstall the game inside
# # ~/.local/share/applications
# https://wiki.archlinux.org/title/desktop_entries
# ==================================================================
echo -e "[Desktop Entry]
Encoding=UTF-8
Categories=Game
Type=Application
Terminal=false
Exec=${uninstaller_file_path}/uninstall_pokemmo
Name=Uninstall PokeMMO
Icon=${default_home_path}data/icons/128x128.png" > ${desktop_file_path}/Uninstall-PokeMMO.desktop

echo -e "${YELLOW}{INFO}${ENDCOLOR} Created the Uninstaller .desktop file! \n"

echo -e "${GREEN}{SUCCESS}${ENDCOLOR} Enjoy the game, to uninstall run: "${WHITE}uninstall_pokemmo${ENDCOLOR} or ${WHITE}run the desktop shortcut${ENDCOLOR}"!\n"
