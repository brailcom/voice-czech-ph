# Configuration

festival_voices_path = /usr/share/festival/voices

# End of configuration

destdir = $(festival_voices_path)/czech/czech_ph

.PHONY: install all-files lpc-files viewcvs-bug

all-files: festvox/czech_ph.scm lpc-files group/ph.group

lpc-files: $(patsubst wav/%.wav, lpc/%.lpc, $(wildcard wav/*.wav))
viewcvs-bug:
	mkdir -p lpc group
lpc/ph0000.lpc: wav/ph0000.wav pm/ph0000.pm viewcvs-bug
	./tools/make_lpc $<
lpc/%.lpc: wav/%.wav pm/%.pm etc/powfacts etc/pf/% viewcvs-bug
	./tools/make_lpc $<

$(wildcard etc/pf/*):
	true

etc/pf/%: etc/powfacts
	fgrep `basename $@` etc/powfacts | head -1 | awk '{ print $$2 }' > $@

# pm-files: $(patsubst wav/%.wav, pm/%.pm, $(wildcard wav/*.wav))
# pm/%.pm: wav/%.wav
# 	./tools/make_pm_wave $<
# 	./tools/make_pm_fix $@

etc/powfacts: $(wildcard lab/*.lab)
	./tools/find_powerfactors lab/*.lab

festvox/czech_ph.scm: festvox/czech_ph.scm.in
	sed 's/DESTDIR/$(subst /,\/,$(destdir))/' $< > $@

group/ph.group: lpc-files
	festival -b make-group.scm

install: $(all-files)
	install -d $(destdir)
	install -d $(destdir)/festvox
	install -m 644 festvox/czech_ph.scm $(destdir)/festvox/
	install -d $(destdir)/group
	install -m 644 group/ph.group $(destdir)/group/
