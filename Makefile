# Configuration

festival_voices_path = /usr/share/festival/voices

# End of configuration

package := voice-czech-ph
version := 0.1

destdir = $(festival_voices_path)/czech/czech_ph

.PHONY: all install uninstall dist dist-src dist-bin lpc-files viewcvs-bug

all: festvox/czech_ph.scm lpc-files group/ph.group

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

clean:
	rm -rf $(package)-$(version) $(package)-$(version).tar
	rm -rf $(package)-bin-$(version) $(package)-bin-$(version).tar
	rm -f $(package)-$(version).tar.gz $(package)-bin-$(version).tar.gz
	rm -f festvox/czech_ph.scm

distclean: clean
	rm -f lpc/* group/*

maintainer-clean: distclean

install: group/ph.group festvox/czech_ph.scm
	install -d $(destdir)
	install -d $(destdir)/festvox
	install -m 644 festvox/czech_ph.scm $(destdir)/festvox/
	install -d $(destdir)/group
	install -m 644 group/ph.group $(destdir)/group/

uninstall:
	rm -f $(destdir)/festvox/czech_ph.scm $(destdir)/group/ph.group
	-rmdir $(destdir)/festvox
	-rmdir $(destdir)/group

dist: clean dist-src dist-bin

dist-src:
	mkdir $(package)-$(version)
	cp -a COPYING INSTALL Makefile README* *.scm dic doc etc festvox lab pm tools wav $(package)-$(version)/
	mkdir $(package)-$(version)/group
	mkdir $(package)-$(version)/lpc
	for d in `find $(package)-$(version) -name CVS -o -name .arch-ids -print`; do rm -r $$d; done
	tar cf $(package)-$(version).tar $(package)-$(version)
	gzip -9 $(package)-$(version).tar

dist-bin: all
	mkdir $(package)-bin-$(version)
	cp -a COPYING INSTALL README* festvox group $(package)-bin-$(version)/
	sed '/festival -b make-group.scm/d' Makefile > $(package)-bin-$(version)/Makefile
	for d in `find $(package)-bin-$(version) -name CVS -o -name .arch-ids -print`; do rm -r $$d; done
	tar cf $(package)-bin-$(version).tar $(package)-bin-$(version)
	gzip -9 $(package)-bin-$(version).tar
