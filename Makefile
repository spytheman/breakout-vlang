all: breakout

breakout: breakout.v
	v breakout.v

clean:
	rm -rf breakout

pack: breakout
	@echo "   `ls -ahs breakout`"
	strip breakout
	@echo "   `ls -ahs breakout`"
	upx -qqq --best breakout
	@echo "   `ls -ahs breakout`"
