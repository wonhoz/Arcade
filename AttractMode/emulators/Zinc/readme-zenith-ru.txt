
 ZeNith 1.0.1.0
 ==============
 
 Сайт ZeNith: http://www.sovmax.narod.ru/zenith/index-ru.html 

 ZeNith 1.0.1.0 (C) 2007 Санников М.А. - http://www.sovmax.narod.ru
 ZiNc 1.1 (C) 1997-2005 Drunken Muppets - http://www.emuhype.com
 Original ZiNc emulator (C) 1997 The_Author & DynaChicken
 ZiNc 1.0 series enhancements (C) 2005 R. Belmont & smf
 ZiNc OpenGL/D3D renderers 1.2 (C) 2004 Pete Bernert & Lewpy
 P.E.Op.S. Software renderer 1.17 (C) 2005 P.E.Op.S. Team
 SPU sound plug-in (C) Pete Bernert - http://www.pbernert.com
 System 11 sound dll (C) R. Belmont - http://rbelmont.mameworld.info
 Winterblast's input plug-in 1.6 (C) 2004 Winterblast
 Arcade history information - http://caesar.logiqx.com
 Техническая поддержка - http://emu-russia.km.ru


 Установка
 =========

 1. Распакуйте содержимое архива ZeNith в каталог эмулятора ZiNc,
    перезаписав файл "s11player.dll"

 2. Поместите ROM-файл "pr1data.8k" в корневой каталог диска C:\.
    Данный файл содержится во всех текущих MAME romset'ах игр на
    платформе System 11 (например, Tekken). Этот файл не должен
    быть в архиве

 3. запустите файл ZeNith.exe


 Замечания
 =========

 1. Игры на оборудовании Konami GV System не работают совместно
    с Winterblast's input plug-in 1.6, поэтому при их запуске
    используется оригинальный plug-in управления из дистрибутива
    ZiNc 1.1 с соответствующей конфигурацией управления

 2. Расширенные настройки видео для P.E.Op.S. Software renderer
    хранятся в реестре Windows. Об этом необходимо помнить при
    использовании данного plug-in'а в других модульных эмуляторах
    Sony PlayStation (например, ePSXe), поскольку при изменении
    настроек в ZeNith'е они изменятся и в других эмуляторах, в
    которых используется данный plug-in, и наоборот
 
 3. Если игра не запускается, нажмите Ctrl+F11, при этом в корневой
    папке эмулятора появится файл zenith.bat. Запустив его вы можете
    посмотреть сообщения консоли ZiNc'a и определить причину проблемы

 4. В архив ZeNith включены следующие файлы сторонних разработчиков:
    - ZiNc OpenGL и D3D renderers 1.2 с сайта http://emuhype.com
    - P.E.Op.S. Software renderer 1.17 с сайта
                                https://sourceforge.net/projects/peops
    - Winterblast's input plug-in 1.6 с сайта http://emulator-zone.com
    - System 11 Player версия от 03.03.06 с официального Форума ZiNc
