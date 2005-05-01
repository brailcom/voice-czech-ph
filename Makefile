# Configuration

festival_voices_path = /usr/share/festival/voices

# End of configuration

destdir = $(festival_voices_path)/czech/czech_ph

.PHONY: default install lpc-files

default: lpc-files festvox/czech_ph.scm

lpc-files: $(patsubst wav/%.wav, lpc/%.lpc, $(wildcard wav/*.wav))
lpc/ph0000.lpc: wav/ph0000.wav pm/ph0000.pm
        ./tools/make_lpc $<
lpc/%.lpc: wav/%.wav pm/%.pm etc/powfacts etc/pf/%
	./tools/make_lpc $<

etc/pf/%: etc/powfacts
	fgrep `basename $@` etc/powfacts | head -1 | awk '{ print $$2 }' > $@

pm-files: $(patsubst wav/%.wav, pm/%.pm, $(wildcard wav/*.wav))
pm/%.pm: wav/%.wav
	./tools/make_pm_wave $<
	./tools/make_pm_fix $@

etc/powfacts: $(wildcard lab/*.lab)
	./tools/find_powerfactors lab/*.lab

festvox/czech_ph.scm: festvox/czech_ph.scm.in
	sed 's/DESTDIR/$(subst /,\/,$(destdir))/' $< > $@

install: default
	install -d $(destdir)
	install -d $(destdir)/festvox
	install -m 644 festvox/czech_ph.scm $(destdir)/festvox/
	install -d $(destdir)/dic
	install -m 644 dic/phdiph.est $(destdir)/dic/
	install -d $(destdir)/lpc
	install -m 644 lpc/*.lpc $(destdir)/lpc/
	install -m 644 lpc/*.res $(destdir)/lpc/
