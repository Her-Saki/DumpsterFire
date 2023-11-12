copy Mindseeker(Japan).nes Mindseeker(Test).nes
schasm Code.asm -o Mindseeker(Test).nes -m nes -wrnerr
Atlas -d debug.log Mindseeker(Test).nes Script.txt > AtlasLog.txt
@pause
