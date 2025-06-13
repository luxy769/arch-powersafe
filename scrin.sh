#!/bin/bash

# Папка для временных скриншотов
DIR="$HOME/Pictures/ClipboardShots"
mkdir -p "$DIR"

# Имя файла с текущим временем
FILENAME="clipshot_$(date +%Y-%m-%d_%H-%M-%S).png"
FULLPATH="$DIR/$FILENAME"

# Сохраняем из буфера обмена в файл
xclip -selection clipboard -t image/png -o > "$FULLPATH"

# Открываем в sxiv
sxiv "$FULLPATH"
