ATSCC=$(ATSHOME)/bin/atscc
ATSOPT=$(ATSHOME)/bin/atsopt

######

ATSCCFLAGS=-O0 -g

######

SOURCES= chameneos_sync.dats chameneos.sats 

OBJECTS := $(SOURCES)
OBJECTS := $(patsubst %.sats, %_sats.o, $(OBJECTS))
OBJECTS := $(patsubst %.dats, %_dats.o, $(OBJECTS))

######

%_sats.o: %.sats ; $(ATSCC) $(ATSCCFLAGS) -c $<
%_dats.o: %.dats ; $(ATSCC) $(ATSCCFLAGS) -c $<

######

chameneos:: chameneos.dats $(OBJECTS)
	$(ATSCC) -D_GNU_SOURCE -D_ATS_MULTITHREAD -o $@ -lpthread $< $(OBJECTS)

######

clean:: ; rm -f *~
clean:: ; rm -f *_?ats.o *_?ats.c
clean:: ; rm -f chameneos

######
