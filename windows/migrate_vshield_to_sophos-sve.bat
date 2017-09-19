fltmc unload vsepflt
\\192.168.1.1\SVE\VMWareTools\setup64.exe /S /v "/qn REBOOT=R ADDLOCAL=ALL REMOVE=FileIntrospection,NetworkIntrospection,Hgfs"
\\192.168.1.2\public\SVE-Guest-Installer.exe SVMIPAddress=192.168.1.2 /install /quiet
