# dependencies:
#    Debian packages: pngquant imagemagick

# List of (country, source, transformation)
COUNTRIES_LIST := countries.txt
COUNTRIES_LIST_CST := $(shell cat $(COUNTRIES_LIST))
# Build a list of flags/COUNTRY.SCALING_METHOD.png
SCALED_FLAGS := $(foreach ft, $(COUNTRIES_LIST_CST), flags/$(word 1, $(subst :, ,$(ft))).$(word 3, $(subst :, ,$(ft))).png)
# Countries for which we don't have the same country code than country-flags (UK + Wales atm)
ALIASES_NEEDED := $(foreach ft, $(COUNTRIES_LIST_CST), \
	$(if $(filter $(word 1, $(subst :, ,$(ft))),$(word 2, $(subst :, ,$(ft)))),,$(word 1, $(subst :, ,$(ft))):$(word 2, $(subst :, ,$(ft)))) \
)
ALIASES_TEMP := $(foreach ft, $(ALIASES_NEEDED), country-flags/png1000px/$(word 1, $(subst :, ,$(ft))).png)

# Outputs
SOURCES_IMG := flags.png flags@2x.png
TARGETS_IMG := $(patsubst %,build/%,$(SOURCES_IMG))
TARGETS_CSS := build/flags.css

# BASE "PHONY" RULES
all: img

img: $(TARGETS_IMG) $(TARGETS_CSS) $(COUNTRIES_LIST) $(SCALED_FLAGS)

# ALIASES
$(foreach ft, $(ALIASES_NEEDED), \
	$(eval country-flags/png1000px/$(word 1, $(subst :, ,$(ft))).png: country-flags/png1000px/$(word 2, $(subst :, ,$(ft))).png ; \
		ln -vs $$(notdir $$<) $$@ \
	) \
)

# IMAGES
flags/%.edge.png: country-flags/png1000px/%.png
	convert -filter Lanczos -depth 24 $< -resize '120x66>' -set option:distort:viewport 120x66 -virtual-pixel edge -distort srt "%[fx:w/2],%[fx:h/2] 1 0 60,33" -alpha off $@

flags/%.fill.png: country-flags/png1000px/%.png
	convert -filter Lanczos -depth 24 $< -resize '120x66^' -gravity center -crop '120x66+0+0' +repage -alpha off $@

flags/%.noratio.png: country-flags/png1000px/%.png
	convert -filter Lanczos -depth 24 $< -resize '120x66!' -gravity center -crop '120x66+0+0' +repage -alpha off $@

build/%.png: %.png
	ls -sh $<
	pngquant --force --speed 1 --verbose - < $< > $@
	ls -sh $@

# SPRITE
flags.png: $(SCALED_FLAGS)
	montage -background black -geometry 60x33!+0+0 $^ -depth 24 $@

flags@2x.png: $(SCALED_FLAGS)
	montage -background black -geometry 120x66!+0+0 $^ -depth 24 $@

flags.shtml: $(SCALED_FLAGS)
	montage -background black -geometry 60x33!+0+0 $^ -depth 24 $@

build/flags.css: flags.shtml flags@2x.png flags.png
	sed -rnf flags-html-to-css.sed $< > $@

# CLEANUP
clean:
	-rm flags/* build/flags.png build/flags@2x.png build/flags.css

.PHONY: prod img clean
.INTERMEDIATE: flags.png flags@2x.png flags.shtml