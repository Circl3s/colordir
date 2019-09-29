# colordir
A module meant to be a purely PowerShell alternative to the written in Ruby, more Linux oriented, amazing colorls.

## Functionality
- [x] Colors
- [x] Icons
- [x] File and folder size calculation
- [x] Name trimming (if it doesn't fit on the screen)
- [x] Different sorting
- [ ] Git integration
- [ ] Tree view
- [ ] Modularity of display

## Installation
Before installing:
Make sure you're using a patched font from [NerdFonts](https://www.nerdfonts.com/). If you're not, either download an already patched font from their site (my suggestions would be BlexMono, FiraCode or Hack), or patch your own using their patching tool.
---
Until I publish it on Powershell Gallery, you'll need to
1. Clone this repository 
  ```
  > git clone https://github.com/Circl3s/colordir.git
  ```
2. Import the module in your Powershell profile (you can find out where it is by echoing `$PROFILE`)
  ```
  Import-Module <Path to where you cloned the module>\colordir.psm1
  ```
3. Add aliases to your profile (optional), for example
  ```
  Set-Alias cdir Get-ColoredItem
  Set-Alias cls Get-ColoredItem
  ```

## Issues
* File/folder name trimming doesn't quite work with some non-English symbols (for example Japanese file names)
* It vomits non-terminating errors if the terminal is too small to even trim the file/folder names
* Due to calculating folder sizes when run, running it for example in C:\ can take a **long** time. Use -IgnoreFolderSizes when necessary.

### If you see icons that are missing...
Check if they are [supported by NerdFonts](https://www.nerdfonts.com/cheat-sheet), and if they are - create an issue or add them and create a pull request, I don't care...