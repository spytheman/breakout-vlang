all: breakout

breakout: breakout.v
	v breakout.v

clean:
	rm -rf breakout

pack: breakout
	@echo "   `ls -ahs breakout`"
	strip breakout
	@echo "   `ls -ahs breakout`"
	upx -qqq --lzma breakout
	@echo "   `ls -ahs breakout`"

microbreakout: breakout
	TARGET=microbreakout; TP=~/vlang/thirdparty ; \
     gcc -w \
     -fno-caller-saves \
     -fno-cse-follow-jumps -fno-hoist-adjacent-loads -fno-inline-small-functions \
     -fno-optimize-sibling-calls -fno-peephole2 -fno-reorder-functions -fno-rerun-cse-after-loop -fno-tree-vrp \
     -fno-reorder-blocks -fno-tree-vect-loop-version \
     -Os \
     -o microbreakout \
     ~/.vlang/breakout.c \
     -I $$TP/glad $$TP/glad/glad.o \
     -I $$TP/glfw -L $$TP/glfw -lglfw \
     -I $$TP/stb_image  \
     -lm -ldl -lpthread ; \
     ls -l $$TARGET; strip $$TARGET; \
     ls -l $$TARGET; upx -qqq --lzma $$TARGET; \
     ls -l $$TARGET
