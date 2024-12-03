build environment :


sudo apt-get install libpq-dev


sudo apt-get install libgtk-3-dev


sudo apt-get install pkg-config


compile:



gcc -o test test.c '`pkg-config --cflags --libs gtk+-3.0` `pkg-config --cflags --libs libpq'`


run:


./test
