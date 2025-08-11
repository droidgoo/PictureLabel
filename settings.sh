#!/bin/bash

smd=PATH_HOLDER/PictureLabel/

echo :::::::::::::::::::
echo   CHANGE SETTINGS
echo :::::::::::::::::::

# show main settings menu
echo prompt for top settings checklist
top=($(kdialog --checklist "Select All Settings<br>To Be Changed" --title "Settings" --separate-output --geometry 200x350+0+0 -- `
    `\1 "Save Directory"    off `
    `\2 "Working Directory" off `
    `\3 "Font Selection"    off `
    `\4 "Font Size"         off `
    `\5 "Line Spacing"      off `
    `\6 "Text Border"       off `
    `\7 "Edge Distance"     off `
    `\8 "Label Opacity"     off `
    `\9 "Advanced Settings" off))
if [ ! $? -eq 0 ]; then
    break
fi

#TODO kdialog --progressbar "top settings progress is a work in progress"

for s in "${top[@]}"; do
    case $s in
        1)  echo edit save directory
            sdir=$(awk -F\" 'NR==1{print $2}' $smd/setdb.txt)
            if [ $sdir == '$HOME' ]; then
                sdir=$HOME
            fi
            sdir=$(kdialog --getexistingdirectory $sdir --title "Saved Pictures Location: $sdir")
            if [ ! $? -eq 0 ]; then
                continue
            fi
            echo write directory to db
            awk -i inplace -v set="$sdir" 'BEGIN{FS=OFS="\""} NR==1{$2=set} {print}' $smd/setdb.txt
        ;;
        2)  echo edit working directory
            wdir=$(awk -F\" 'NR==2{print $2}' $smd/setdb.txt)
            if [ $wdir == '$HOME' ]; then
                wdir=$HOME
            fi
            wdir=$(kdialog --getexistingdirectory $wdir --title "Working Files Location: $wdir")
            if [ ! $? -eq 0 ]; then
                continue
            fi
            echo write directory to db
            awk -i inplace -v set="$wdir" 'BEGIN{FS=OFS="\""} NR==2{$2=set} {print}' $smd/setdb.txt
        ;;
        3)  echo set font selection
            font=$(awk -F\" 'NR==3{print $2}' $smd/setdb.txt)
            while true ;do
                look=$(kdialog --menu "Current Font: $font" --geometry 300x950+0+0 --title "Font Selector" --default $font -- `
                    `\Liberation-Sans-Bold                'BOLD sans Liberation' `
                    `\Open-Sans-Extrabold                 'BOLD sans Open Impact' `
                    `\Open-Sans-Extrabold-Italic          'BOLD sans Open Italic' `
                    `\Nimbus-Sans-Bold-Italic             'BOLD sans Nimbus Italic' `
                    `\Nimbus-Sans-Narrow-Bold             'BOLD sans Nimbus Narrow' `
                    `\Nimbus-Sans-Narrow-Bold-Oblique     'BOLD sans Nimbus Narrow Oblique' `
                    `\Noto-Sans-Display-Bold              'BOLD sans Noto' `
                    `\Noto-Sans-Bold-Italic               'BOLD sans Noto Italic' `
                    `\Noto-Serif-Bold                     'BOLD serif Noto' `
                    `\Noto-Serif-Bold-Italic              'BOLD serif Noto Italic' `
                    `\Liberation-Serif-Bold-Italic        'BOLD serif Liberation Italic' `
                    `\FreeMono-Bold                       'BOLD mono Free serif' `
                    `\FreeMono-Bold-Oblique               'BOLD mono Free Oblique serif' `
                    `\Noto-Sans-Mono-Bold                 'BOLD mono Noto sans' `
                    `\DejaVu-Sans-Mono-Bold-Oblique       'BOLD mono DejaVu Oblique sans' `
                    `\Liberation-Sans                     'NORM sans Liberation' `
                    `\Noto-Sans-Display-Regular           'NORM sans Noto' `
                    `\Noto-Sans-Display-Italic            'NORM sans Noto Italic' `
                    `\URWGothic-Demi                      'NORM sans URWGothic Demi' `
                    `\URWGothic-DemiOblique               'NORM sans URWGothic Demi Oblique' `
                    `\Nimbus-Sans-Narrow-Regular          'NORM sans Nimbus Narrow' `
                    `\Nimbus-Sans-Narrow-Oblique          'NORM sans Nimbus Narrow Oblique' `
                    `\Noto-Serif-Regular                  'NORM serif Noto' `
                    `\Noto-Serif-Italic                   'NORM serif Noto Italic' `
                    `\Liberation-Serif-Italic             'NORM serif Liberation Italic' `
                    `\Noto-Sans-Mono-Regular              'NORM mono Noto' `
                    `\DejaVu-Sans-Mono-Oblique            'NORM mono DejaVu Oblique' `
                    `\Open-Sans-Light                     'LITE sans Open' `
                    `\Open-Sans-Light-Italic              'LITE sans Open Italic' `
                    `\URWGothic-Book                      'LITE sans URWGothic Book' `
                    `\Nimbus-Mono-PS-Regular              'LITE mono Nimbus' `
                    `\Nimbus-Mono-PS-Italic               'LITE mono Nimbus Italic' `
                    `\FreeMono                            'LITE mono Free' `
                    `\FreeMono-Oblique                    'LITE mono Free Oblique' `
                    `\search                              '** Search Available Fonts **')
                if [ ! $? -eq 0 ]; then
                    continue 2
                fi
                if [ $look == "search" ]; then
                    searchterm=$(kdialog --inputbox "Enter search term" --title "Search" --geometry 200x100+0+0)
                    if [ ! $? -eq 0 ]; then
                        continue 2
                    fi
                    searchresult=$(identify -list font | grep -Ei "font: .*$searchterm.*$" | sort | sed -e 's/^.*: //')
                    kdialog --textinputbox  "Fonts matching your search..."  "$searchresult" --title "Search Result" --geometry 400x700+0+0 &
                    dresult=$!
                    look=$(kdialog --inputbox  "Paste font name here" --title "Get Font" --geometry 300x100+400+0)
                    if [ ! $? -eq 0 ]; then
                        kill $dresult
                        continue 2
                    fi
                    kill $dresult
                fi
                kfontview -geometry +0+0 $(identify -list font | grep -A5 "$look" | awk  'NR==6{print $2}') &
                dfon=$!
                sleep 1
                kdialog --title "ACCEPT" --yesno "Showing the\n$look\nfont..." --yes-label "Accept" --no-label "Redo" --geometry +700+0
                if [ $? -eq 0 ]; then
                    echo font ACCEPTED!
                    kill $dfon
                    break
                elif [ $? -eq 2 ]; then
                    kill $dfon
                    continue 2
                fi
                kill $dfon
                echo choose different font
            done
            echo write font to db
            awk -i inplace -v set="$look" 'BEGIN{FS=OFS="\""} NR==3{$2=set} {print}' $smd/setdb.txt
        ;;
        4)  echo set font size
            sfsz=$(awk -F\" 'NR==4{print $2}' $smd/setdb.txt)
            sfsz=$(kdialog --combobox "Select Size" "8" "10" "12" "14" "16" "18" "20" "24" "30" "36" "42" "48" "60" "72" --title "Font Size" --geometry 250x150+0+0 --default $sfsz)
            if [ ! $? -eq 0 ]; then
                continue
            fi
            echo write font size to db
            awk -i inplace -v set="$sfsz" 'BEGIN{FS=OFS="\""} NR==4{$2=set} {print}' $smd/setdb.txt
        ;;
        5)  echo edit line spacing
            slns=$(awk -F\" 'NR==5{print $2}' $smd/setdb.txt)
            slns=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Set distance between text lines<br>Current Line Spacing:[$slns]")</FONT>" --title "Line Spacing" --geometry 200x100+0+0)
            if [ ! $? -eq 0 ] || [ -z $slns ]; then
                continue
            fi
            echo write line spacing to db
            awk -i inplace -v set="$slns" 'BEGIN{FS=OFS="\""} NR==5{$2=set} {print}' $smd/setdb.txt

        ;;
        6)  echo edit border spacing
            sbdr=$(awk -F\" 'NR==6{print $2}' $smd/setdb.txt)
            sbdr=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Set [w]x[h] of border around text<br>Current Border Spacing:[$sbdr]")</FONT>" --title "Border Size" --geometry 200x100+0+0)
            if [ ! $? -eq 0 ] || [ -z $slns ]; then
                continue
            fi
            echo write border spacing to db
            awk -i inplace -v set="$sbdr" 'BEGIN{FS=OFS="\""} NR==6{$2=set} {print}' $smd/setdb.txt
        ;;
        7)  echo edit edge spacing
            sesp=$(awk -F\" 'NR==7{print $2}' $smd/setdb.txt)
            sesp=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Set distance from picture edge<br>Current Edge Spacing:[$sesp]")</FONT>" --title "Edge Spacing" --geometry 200x100+0+0)
            if [ ! $? -eq 0 ] || [ -z $slns ]; then
                continue
            fi
            echo write border spacing to db
            awk -i inplace -v set="$sesp" 'BEGIN{FS=OFS="\""} NR==7{$2=set} {print}' $smd/setdb.txt
        ;;
        8)  echo edit label opacity
            opac="$(awk -F\" 'NR==8{print $2}' $smd/setdb.txt)"
            case $opac in
                FF) opap='100'   ;;
                FC) opap=' 98'   ;;
                FA) opap=' 99'   ;;
                F7) opap=' 97'   ;;
                F2) opap=' 95'   ;;
                E6) opap=' 90'   ;;
                D9) opap=' 85'   ;;
                CC) opap=' 80'   ;;
                BF) opap=' 75'   ;;
                A6) opap=' 65'   ;;
                80) opap=' 50'   ;;
                    *) ;;
            esac
            sopc=$(kdialog --menu "<FONT FACE="Mono">$(echo "Label Opacity<br>is currently: $opap%")</FONT>" --default "$opap" --title "Label Opacity" --geometry 0x360+0+0 -- `
                `\FF      '100' `
                `\FC      ' 98' `
                `\FA      ' 99' `
                `\F7      ' 97' `
                `\F2      ' 95' `
                `\E6      ' 90' `
                `\D9      ' 85' `
                `\CC      ' 80' `
                `\BF      ' 75' `
                `\A6      ' 65' `
                `\80      ' 50')
            if [ ! $? -eq 0 ]; then
                continue
            fi
            awk -i inplace -v set="$sopc" 'BEGIN{FS=OFS="\""} NR==8{$2=set} {print}' $smd/setdb.txt
        ;;
        9)  echo prompt for advanced settings checklist
            adv=($(kdialog --checklist "Edit Screen Positions of<br>Windows, Messages and Prompts" --separate-output --title "Advanced Settings" --geometry 200x350+0+0 -- `
                `\9  "Picture Display"          off `
                `\10 "Locations Menu"           off `
                `\11 "Location Message"         off `
                `\12 "Text Input Prompt"        off `
                `\13 "Background Color Picker"  off `
                `\14 "Font Color Menu"          off `
                `\15 "Custom Color Input"       off `
                `\16 "Accept/Redo Prompt"       off `
                `\17 "Manual Edit/Reset"        off))
            if [ ! $? -eq 0 ]; then
                continue
            fi
#TODO kdialog --progressbar"advanced<br>settings<br>progress<br>i<br>s<br>a<br>work<br>in<br>progress"

            for a in "${adv[@]}"; do
                case "$a" in
                    9)
                        echo picture display geometry
                        swin=$(awk -F\" 'NR==9{print $2}' $smd/setdb.txt)
                        swin=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Picture Display<br>Current Geometry:[$swin]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $swin ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$swin" 'BEGIN{FS=OFS="\""} NR==9{$2=set} {print}' $smd/setdb.txt
                    ;;
                    10)
                        echo location menu geometry
                        sloc=$(awk -F\" 'NR==10{print $2}' $smd/setdb.txt)
                        sloc=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Locations Menu<br>Current Geometry:[$sloc]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $sloc ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$sloc" 'BEGIN{FS=OFS="\""} NR==10{$2=set} {print}' $smd/setdb.txt
                    ;;
                    11)
                        echo message display geometry
                        smsg=$(awk -F\" 'NR==11{print $2}' $smd/setdb.txt)
                        smsg=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Location Message<br>Current Geometry:[$smsg]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $smsg ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$smsg" 'BEGIN{FS=OFS="\""} NR==11{$2=set} {print}' $smd/setdb.txt
                    ;;
                    12)
                        echo text prompt geometry
                        stxt=$(awk -F\" 'NR==12{print $2}' $smd/setdb.txt)
                        stxt=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Text Input Prompt<br>Current Geometry:[$stxt]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $stxt ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$stxt" 'BEGIN{FS=OFS="\""} NR==12{$2=set} {print}' $smd/setdb.txt
                    ;;
                    13)
                        echo background picker geometry
                        sbgc=$(awk -F\" 'NR==13{print $2}' $smd/setdb.txt)
                        sbgc=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Background Color Picker<br>Current Geometry:[$sbgc]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $sbgc ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$sbgc" 'BEGIN{FS=OFS="\""} NR==13{$2=set} {print}' $smd/setdb.txt
                    ;;
                    14)
                        echo font color menu geometry
                        stxc=$(awk -F\" 'NR==14{print $2}' $smd/setdb.txt)
                        stxc=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Font Color Menu<br>Current Geometry:[$stxc]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $stxc ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$stxc" 'BEGIN{FS=OFS="\""} NR==14{$2=set} {print}' $smd/setdb.txt
                    ;;
                    15)
                        echo custom color input geometry
                        shex=$(awk -F\" 'NR==15{print $2}' $smd/setdb.txt)
                        shex=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Custom Color Input<br>Current Geometry:[$shex]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $shex ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$shex" 'BEGIN{FS=OFS="\""} NR==15{$2=set} {print}' $smd/setdb.txt
                        ;;
                    16)
                        echo accept prompt geometry
                        sacc=$(awk -F\" 'NR==16{print $2}' $smd/setdb.txt)
                        sacc=$(kdialog --inputbox "<FONT FACE="Mono">$(echo "Accept/Redo Prompt<br>Current Geometry:[$sacc]")</FONT>" --title "Geomety" --geometry 200x100+0+0)
                        if [ ! $? -eq 0 ] || [ -z $sacc ]; then
                            continue
                        fi
                        echo write border spacing to db
                        awk -i inplace -v set="$sacc" 'BEGIN{FS=OFS="\""} NR==16{$2=set} {print}' $smd/setdb.txt
                    ;;
                    17)
                        echo manual settings editor or factory reset
                        kdialog --warningyesnocancel "Manual edit risks damage to settings file<br>A damaged file can be factory reset" --yes-label "Proceed at Risk" --no-label "Factory Reset" --cancel-label "Quit" --title "WARNING!"
                        ans=$?
                        case $ans in
                            0)
                                manual="$(cat $smd/setdb.txt)"
                                manual=$(kdialog --textinputbox "Settings Database" --title "Settings Editor" --geometry 700x400+0+0 "$manual")
                                if [ ! $? -eq 0 ]; then
                                    continue
                                fi
                                echo "$manual" >$smd/setdb.txt
                            ;;
                            1)
                                echo copy the factory db back
                                cp ~/.local/share/kservices5/PictureLabels/setdb.txt.bak ~/.local/share/kservices5/PictureLabels/setdb.txt
                                kdialog --msgbox "reset"
                            ;;
                            2)
                                echo do nothing and quit
                            ;;
                            *)
                            ;;
                        esac
                    ;;
                esac
            done
        ;;
        *)
        ;;
    esac
done

echo :::::::::::::::::::
echo   All DONE
echo :::::::::::::::::::
