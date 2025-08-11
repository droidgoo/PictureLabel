#!/bin/bash

smd=PATH_HOLDER/PictureLabel/

prev="
Accept
  - or -
 Redo
"
# import settings
source $smd/setdb.txt
clear

# test for imagemagick version and prepend appropriate command ahead of each imagemagick call
if [ $(convert -version | grep Version: | sed -E 's/^[^0-9]*([0-9]).*$/\1/') -eq 6 ] ; then
    mgk=""
elif [ $(magick -version | grep Version: | sed -E 's/^[^0-9]*([0-9]).*$/\1/') -eq 7 ]; then
    mgk="magick"
elif [ $(imagemagick -version | grep Version: | sed -E 's/^[^0-9]*([0-9]).*$/\1/') -eq 7 ]; then
    mgk="imagemagick"
fi

echo ::::::::::::::::::::
echo main picture loop
echo ::::::::::::::::::::

# take files passed by service menu and assign to an array
see=($@)

# find all items in directory with image mime type and strip off everything after the file name
for files in $(file -i ${see[@]} | grep image | sed -e "s/:.*$//"); do                  # picture loop
    # keep file name and strip off the directory tree
    b=$(basename $files)
    # keep name and strip off file extension
    n=${b%.*}
    # strip off file name and keep extension
    e=${b/#$n/}

    # set up pristine picture files for labeling
    echo $mgk ; convert $files  $data_dir/$n.png
    cp $data_dir/$n.png $save_dir/$n.png

    # set up data file if does not exist
    if [ ! -f $data_dir/$n-db.txt ]; then
        echo -e "\`" >$data_dir/$n-db.txt
        for (( i=2; i<=9; i++)); do
            if [ $i -eq 7 ] || [ $i -eq 8 ]; then
                echo -e ":::::\`" >>$data_dir/$n-db.txt
            elif [ $i -eq 9 ]; then
                echo -e "on off off off off off\`" >>$data_dir/$n-db.txt
            else
                echo -e "\`" >>$data_dir/$n-db.txt
            fi
        done
    fi

    # look for legacy picture labels in the current folder and apply to SouthWest location, if found
    if [ -f text/$n-text.txt ]; then
        echo legacy label text detected for file $n: importing...
        legacy_blrb=$(cat text/$n-text.txt)
        awk -i inplace -v blb="$legacy_blrb" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==1{$0=blb} {print}' $data_dir/$n-db.txt
        mv text/$n-text.txt text/$n-text.txtold
    fi
    if [ -f text/$n.txt ]; then
        echo legacy label colors detected for file $n: importing...
        legacy_bkgr=$(cat text/$n.txt | grep "colorcode=" | sed -e "s/colorcode=//")
        awk -i inplace -v col="$legacy_bkgr" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==7{$1=col} {print}' $data_dir/$n-db.txt
        legacy_fcol=$(cat text/$n.txt | grep "textcolor=" | sed -e "s/textcolor=//")
        awk -i inplace -v col="$legacy_fcol" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==8{$1=col} {print}' $data_dir/$n-db.txt
        mv text/$n.txt text/$n.txtold
    fi

    echo ::::::::::::::::::::
    echo while pic in-work
    echo ::::::::::::::::::::

    while true ;do                                                          # while pic in-work

        # show picture for labeling
        echo picture $pwin
        echo [[[display]]] pic in-work
        echo $mgk ; display -geometry $pwin $data_dir/$n.png &
        dpic=$!                 # [[[display]]] in-work pic

        # load previous location data or default Southwest location
        compass=($(awk 'BEGIN{RS="`\n";ORS=""} NR==9{print $0}' $data_dir/$n-db.txt))

        # prompt for locations to label with previous locations pre-highlighted
        echo locations checklist $ploc
        echo prompt for label locations
        loc=($(kdialog --checklist "Label Locations (pick all that apply)" 1 "Southwest" ${compass[1-1]} 2 "South" ${compass[2-1]} 3 "Southeast" ${compass[3-1]} 4 "Northeast" ${compass[4-1]} 5 "North" ${compass[5-1]} 6 "Northwest" ${compass[6-1]} --title "Label Locations" --geometry $ploc --separate-output))
                            if [ $? -eq 1 ]; then
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                break 5
                            fi
        # reset locations counter to process new locations chosen
        compass=(off off off off off off)

        echo :::::::::::::::::::
        echo begin moving thru locations
        echo :::::::::::::::::::

        #process each location for labeling
        for l in "${loc[@]}"; do                                        # locations loop

            # convert prompt output into meaningful imagemagick variables
            # for label location and text justification within each label
            # then update locations counter for later database storage
            case "$l" in
                1)  location[$l]=SouthWest
                    jtxt=West
                    compass[$l-1]=on ;;
                2)  location[$l]=South
                    jtxt=Center
                    compass[$l-1]=on ;;
                3)  location[$l]=SouthEast
                    jtxt=East
                    compass[$l-1]=on ;;
                4)  location[$l]=NorthEast
                    jtxt=East
                    compass[$l-1]=on ;;
                5)  location[$l]=North
                    jtxt=Center
                    compass[$l-1]=on ;;
                6)  location[$l]=NorthWest
                    jtxt=West
                    compass[$l-1]=on ;;
                *)  ;;
            esac

            # show message to indicate current worksite for label
            echo working location $pmsg
            echo [[[display]]] message of work location
            kdialog --msgbox "${location[$l]}" --title "Location" --geometry $pmsg &
            dloc=$!             # [[[display]]] message

            echo :::::::::::::::::::
            echo gather label data
            echo :::::::::::::::::::

            # cycle thru label creation until is is acceptable
            while true ; do                                         # while label in-work

                # load label text and colors or set variables to NULL
                blrb=$(awk -v k="$l" 'BEGIN{RS="`\n";ORS="";FS=":"} NR==k{print $0}' $data_dir/$n-db.txt)
                bkgr=$(awk -v m="$l" 'BEGIN{RS="`\n";ORS="";FS=":"} NR==7{print $m}' $data_dir/$n-db.txt)
                    bkgr=${bkgr::7}
                fcol=$(awk -v m="$l" 'BEGIN{RS="`\n";ORS="";FS=":"} NR==8{print $m}' $data_dir/$n-db.txt)

                # output to a terminal window (if used) to show database being read in
                echo check if all location defaults were read in correctly
                echo
                echo -e "blurb:\n$blrb"
                echo -e bkgr="$bkgr"
                echo -e fcol="$fcol"
                echo -e "locations:\n${compass[@]}"
                echo

                # prompt for text creation or editing of label text
                echo text input box $ptxt
                echo prompt for label string edit using prompt variable
                blrb=$(kdialog --textinputbox "Write Label" --title "Label Text" --geometry $ptxt "$blrb")
                awk -i inplace -v k="$l" -v blb="$blrb" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==k{$0=blb} {print}' $data_dir/$n-db.txt
                            if [ $? -eq 1 ]; then
                                kill $dloc
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                break 5
                            fi
                # prompt for label background color to select from from image
                echo background color picker $pbgc
                echo prompt for background color edit using prompt variable
                bkgr=$(kdialog  --getcolor --title "Choose label background color:" --geometry $pbgc --default "$bkgr")
                            if [ $? -eq 1 ]; then
                                kill $dloc
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                break 5
                            fi
                bkgr+=$opac
                awk -i inplace -v m="$l" -v col="$bkgr" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==7{$m=col} {print}' $data_dir/$n-db.txt

                # prompt for text color or pass existing color to "custom"
                echo text color menu $ptxc
                echo prompt for text color menu with custom as default
                tc=$(kdialog --menu "Select Color" 1 "Black" 2 "White" 3 "Red" 4 "Yellow" 5 "Green" 6 "Magenta" 7 "Custom" --default "Custom" --title "Text Color" --geometry $ptxc)
                            if [ $? -eq 1 ]; then
                                kill $dloc
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                break 5
                            fi
                case $tc in
                    1)  fcol="#0F0F0F" ;;
                    2)  fcol="#FFFAFA" ;;
                    3)  fcol="#EE0000" ;;
                    4)  fcol="#EEEE00" ;;
                    5)  fcol="#00EE00" ;;
                    6)  fcol="#EE00EE" ;;
                    7)  echo color code input $phex
                        fcol=$(kdialog --inputbox "Enter Hex Code" $fcol --title "Custom Color" --geometry $phex) ;;
                esac
                awk -i inplace -v m="$l" -v col="$fcol" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==8{$m=col} {print}' $data_dir/$n-db.txt

#TODO make some adjustment to border size based on font size and maybe do away with it in settings.
                ######################################################
                # create temporary label image file using imagemagick
                ######################################################

                echo generate label image
                echo "$blrb" | $(echo $mgk ; convert -gravity $jtxt -background "#00000000" -fill $fcol -font $font -pointsize $ptsz text:- -interline-spacing $lnsp  -trim +repage -bordercolor $bkgr -border $brdr $data_dir/lab_tmp-$l.tif)

                ###########################################################
                # merge temporary label image with in-work copy of picture
                ###########################################################

                echo apply label to in-work pic
                echo $mgk ; composite -gravity "${location[$l]}" -geometry $edgs $data_dir/lab_tmp-$l.tif $data_dir/$n.png $data_dir/$n.png

                # refresh image display to show the applied label
                echo [[[kill]]] pic in-work
                kill $dpic      # [[[kill]]] pic with no or previous label
                echo picture $pwin
                echo [[[display]]] pic in-work
                echo $mgk ; display -geometry $pwin $data_dir/$n.png &
                dpic=$!         # [[[display]]] pic in-work with newly added label p+1

                # prompt to accept the label change before moving on to the next location
                echo accept/redo $pacc
                echo prompt for label complete
                kdialog --yesno "$prev" --yes-label "Accept" --no-label "Redo" --title "Label Complete" --geometry $pacc
                if [ $? -eq 0 ]; then
                    echo label ACCEPTED!
                    echo [[[kill]]] message
                    kill $dloc  # [[[kill]]] message
                    cp $data_dir/$n.png $save_dir/$n.png
                    break               # exit s the loop
                elif [ $? -eq 2 ]; then
                                kill $dloc
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                rm $data_dir/lab_tmp-$l.tif
                                break 5
                fi

                # restore picture to previous state and start over with label creation/editing
                echo [[[kill]]] pic only
                kill $dpic      # [[[kill]]] pic
                cp $save_dir/$n.png $data_dir/$n.png
                echo picture $pwin
                echo [[[display]]] pic in-work
                echo $mgk ; display -geometry $pwin $data_dir/$n.png &
                dpic=$!         # [[[display]]] in-work pic

                echo ::::::::::::::::::
                echo redo label creation
                echo ::::::::::::::::::

            done                                                    # while label in-work

            # clean up temporary files from successful label creation
            rm $data_dir/lab_tmp-$l.tif
            echo :::::::::::::::::::
            echo on to the next label location
            echo :::::::::::::::::::

        done                                                            # locations loop

        echo ::::::::::::::::::::
        echo all labels completed
        echo ::::::::::::::::::::



        # prompt to accept the final picture changes before moving on to the next picture
        echo prompt for picture complete
        echo accept/redo $pacc
        kdialog --yesno "$prev" --yes-label "Accept" --no-label "Redo" --title "Picture Complete" --geometry $pacc
        if [ $? -eq 0 ]; then
            echo picture ACCEPTED!

            # check picture db for orphan text inputs and handle them as needed
            i=1
            for o in ${compass[@]}; do
                if [ $o == "off" ]; then
                    orph=$(awk -v k="$i" 'BEGIN{RS="`\n";ORS="";FS=":"} NR==k{print $0}' $data_dir/$n-db.txt)
                    if [ ! -z "$orph" ]; then
                        echo you have orphaned text at location $i
                        echo prompt for action to take
                        echo
                        kdialog --warningyesnocancel "$orph" --title "This picture has orphaned text" --yes-label "Save to a file" --no-label "Delete text" --cancel-label "Do nothing"
                        ans=$?
                        case $ans in
                            0)  echo save to a file
                                kdialog   --getsavefilename . text/plain  --title "Save the orphans!"
                                awk -i inplace -v k="$i" -v blb="" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==k{$0=blb} {print}' $data_dir/$n-db.txt
                            ;;
                            1)  echo delete text from db
                                awk -i inplace -v k="$i" -v blb="" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==k{$0=blb} {print}' $data_dir/$n-db.txt
                            ;;
                            2)  echo keep text in db ;;
                            *)
                            ;;
                        esac
                    fi
                fi
                ((i++))
            done

            # save modified picture in output directory under the original image type
            echo $mgk ; convert $data_dir/$n.png $save_dir/$n$e

            # clean up working files and display
            rm $data_dir/$n.png
            rm $save_dir/$n.png
            kill $dpic          # [[[kill]]] pic in-work  done with labeling

            # record active label locations
            awk -i inplace -v com="$(echo ${compass[@]})" 'BEGIN{RS=ORS="`\n";FS=OFS=":"} NR==9{$0=com} {print}' $data_dir/$n-db.txt

            break

        elif [ $? -eq 2 ]; then
                                kill $dpic
                                rm $data_dir/$n.png
                                rm $save_dir/$n.png
                                break 5
        fi

        # close picture display ahead of starting over with labeling the picture from the first location
        kill $dpic              # [[[kill]]] pic in-work

        # set up pristine picture files for labeling
        echo $mgk ; convert $files  $data_dir/$n.png
        cp $data_dir/$n.png $save_dir/$n.png

        echo ::::::::::::::::
        echo redo picking locations
        echo ::::::::::::::::

    done                                                                    # while pic in-work

    echo ::::::::::::::::::
    echo go on to next picture
    echo ::::::::::::::::::

done                                                                            # picture loop

echo ::::::::::::::::::
echo all done !!!
echo ::::::::::::::::::
