# myHD_APKG tool
## **How to create APKG for myHD Idesk**
ALL must be run in a ssh terminal user : **root** / **your_admin_password**
1. create a folder in Asustor x86_64 NAS ex. **myHD** (I use it in future example)
2. Install git (APKG or Entware APKG) on your NAS
3. clone git myHD_apkg, this create a myHD_apkg folder with all what you need
4. create folders (or this folders will be created by app_mngt.sh) under myHD base folder named : **apkg** and **files**  
this folder receive for **apkg** the result MHI-xxxx.apk, for **files** the extra files required (.deb, AppImage, compiled App., etc.)  
ex. myHD/files/APKG_NAME/fileXX/the_file_or_files  
XX=**16**, **18** or **20** for Ubuntu version in myHD OR **I** for Idesk(20.04) in myHD
5. create your APKG_NAME in myHD_apkg/AppsI/ and use examples for your target
    - **molotov-A**, **calibre-A** is for AppImage application
    - **firefox** is for Ubuntu 20.04 web browser  
    - **netflix**, **youtube**, **etc**. for Chrome direct access to the site with VA-API (video acceleration anble)  
    - **support** open a browser with URL (here the Asustor support page) so you can create icon to directly access web applications (job, advertasing, etc.)  
    - **MH-test** is to show how calling an Asportal application from myHD Idesk ... not all is possible because for ex. Asportal firefox kill all pulseaudio server, so this require to patch the shell or restart myHD pulseaudio server after using Asportal/Firefox (I don't understand why Asustor kill all when it's possible to kill it for Asportal only ????  )
6. create icons, got to genere_icons/save and put a **SQUARE** size icons (any size but result is resized to 90x90 and 130x130 for all require icons) also select a background for the Idesk icon; Then use the script to generate the icons :  
**./create_idesk_icon.sh APKG.png ../back/fond_bleu_idesk.png** (other colors are provide), this generate icon for A.D.M. / AppCentral and the Idesk icon.  
When it's ready ... copy icons : **cp APKG\*.png ../AppsI/APKG_NAME/**
7. return to myHD_apkg/AppsI/APKG_NAME and create **APKG_NAME.cfg** based on example (I write later more explain)
8. create an install folder, inside only file require are **APKG_NAME.sh** (launcher) and **install.inc** (even an empty file is created if not provide), the other files are created automatically : ***install.sh install.inc APKG_NAME.lnk*** (Idesk icon definition)
9. optional, put files to add in files/APKG_NAME/filesI/
10. generate the **APKG_NAME.apk** for install manually or using AppCentral  
    - in myHD_apkg folder : **./apkg_mngt.sh create APKG_NAME I** (I is for Idesk target)      

**example of APKG.cfg** (after ... it's comment here not in real) 

    [%NAME%]  ... APKG name
    Version = 1.1  
    Shell = %NAME%.sh  ...  bash start shell for APKG
    Fond = fond_noir.png  ... only for Asportal NOR for Idesk
    iconIdesk = %NAME%-Idesk.png  ... only for Idesk
    caption = "Any text"  ... text under icon in Idesk
    Ctrl = xbmc  ... only Asportal remote control
    %% config_json = filename  ... specific depends (ex. firefox added to myHD)
    %% appimage = xxxxxx.AppImage  ... AppImage in files/APKG/filesI/appimage
    url = "https://support.asustor.com/" ... url for chrome or firefox direct call
    
**End of APKG.cfg file example**


More details will be provide later.  
Philippe.
