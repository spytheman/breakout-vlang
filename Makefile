all: breakout

breakout: breakout.v
	vlang breakout.v

clean:
	rm -rf breakout
