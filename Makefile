# dependencies:
#    Debian packages: pngquant imagemagick

SOURCES_FLAGS=$(wildcard flags/*.png)
SOURCES_IMG=flags.png flags@2x.png
TARGETS_IMG=build $(patsubst %,build/%,$(SOURCES_IMG))
TARGETS_CSS=build/flags.css

# BASE "PHONY" RULES
all: img

img: $(TARGETS_IMG) $(TARGETS_CSS)

# IMAGES
build/%.png: %.png
	ls -sh $<
	pngquant --force --speed 1 --verbose - < $< > $@
	ls -sh $@

# SPRITE
flags.png: $(SOURCES_FLAGS)
	montage -background black -geometry 60x33!+0+0 $^ -depth 8 $@

flags@2x.png: $(SOURCES_FLAGS)
	montage -background black -geometry 120x66!+0+0 $^ -depth 8 $@

flags.shtml: $(SOURCES_FLAGS)
	montage -background black -geometry 60x33!+0+0 $^ -depth 8 $@

build/flags.css: flags.shtml flags@2x.png flags.png
	sed -rnf flags-html-to-css.sed $< > $@

# CLEANUP
clean:
	-rm -r build/* flags.png flags@2x.png flags.shtml

.PHONY: prod img clean
.INTERMEDIATE: flags.png flags@2x.png flags.shtml