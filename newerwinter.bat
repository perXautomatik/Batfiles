cd /d "D:\Games\GOG.com\Neverwinter Nights Diamond Edition\Neverwinter Nights Diamond Edition\saves"
for /f "tokens=1-5 delims=:" %%d in ("%time%") do rename "D:\Games\GOG.com\Neverwinter Nights Diamond Edition\Neverwinter Nights Diamond Edition\saves\000000 - quicksave" "%%d%%e%%f-quicksave"
cd /d "D:\Games\GOG.com\Neverwinter Nights Diamond Edition\Neverwinter Nights Diamond Edition\saves"
for /f "tokens=1-5 delims=:" %%d in ("%time%") do rename "D:\Games\GOG.com\Neverwinter Nights Diamond Edition\Neverwinter Nights Diamond Edition\saves\000001 - Auto Save" "%%d%%e%%f-Auto Save"