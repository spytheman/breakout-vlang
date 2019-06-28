all: breakout

breakout: breakout.v
	v breakout.v

clean:
	rm -rf breakout

pack: breakout
	@ls -lart breakout
	@strip breakout
	@ls -lart breakout
	@upx -qqq --best breakout
	@ls -lart breakout
