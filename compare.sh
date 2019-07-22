echo "without sse";
time ./bitmap img.bmp 50


echo "with sse";
time ./bitmap img.bmp 50 --sse
