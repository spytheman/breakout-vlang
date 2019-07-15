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
