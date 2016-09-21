# Get the user SID to change registry key
$user = Get-WmiObject win32_useraccount -Filter "name = 'Utilisateur'"
$sid = $user.sid
Set-Itemproperty -path "Registry::HKEY_USERS\${sid}\Control Panel\Desktop" -name WallPaper -value "C:\Airwatch\wallpaper.jpg"

# Move the picture
Move-Item C:\Airwatch\Products\Wallpaper\wallpaper.jpg C:\Airwatch\ -Force

# Call the Win32 API for change
Add-Type @"
using System;
 using System.Runtime.InteropServices;
 using Microsoft.Win32;

 namespace Wallpaper
 {
   public enum Style : int
   {
     Tile, Center, Stretch, NoChange
   }

   public class Setter {
     public const int SetDesktopWallpaper = 20;
     public const int UpdateIniFile = 0x01;
     public const int SendWinIniChange = 0x02;
     [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
     private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);

     public static void SetWallpaper ( string path, Wallpaper.Style style ) {
       SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
     }
   }
 }
"@

[Wallpaper.Setter]::SetWallpaper('C:\Airwatch\wallpaper.jpg', 0)
