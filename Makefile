VERSION := 0.0
RELEASE := 0.5

UNAME := $(shell uname -o)

ifeq ($(UNAME),Cygwin)
CLASSPATH = '$(shell cygpath -wsp .:$(JARS))'
PWD := $(shell cygpath -d $(shell pwd))\\
LAUNCH4J := launch4jc
SCP := pscp
else
CLASSPATH = .:$(JARS)
PWD := $(shell pwd)/
LAUNCH4J := /usr/local/launch4j/launch4j
SCP := scp
endif

MP_SOURCES= HexValue.java Map.java Parser.java Parse.java \
	    ParserException.java Project.java MapData.java

LF_SOURCES= Dataset.java Units.java CSVFileFilter.java CSVRow.java

UT_SOURCES= ExitListener.java WindowUtilities.java Cursors.java \
	    WaitCursor.java MMapFile.java \
	    MenuListener.java SubActionListener.java \
	    GenericFileFilter.java Unsigned.java DoubleArray.java

EX_SOURCES= ECUxPlot.java ECUxChartFactory.java ECUxDataset.java AxisMenu.java

MP_CLASSES=$(MP_SOURCES:%.java=org/nyet/mappack/%.class)
LF_CLASSES=$(LF_SOURCES:%.java=org/nyet/logfile/%.class)
UT_CLASSES=$(UT_SOURCES:%.java=org/nyet/util/%.class)
EX_CLASSES=$(EX_SOURCES:%.java=org/nyet/ecuxplot/%.class)

TARGETS=mapdump.class $(EX_CLASSES)
REFERENCE=data/4Z7907551R.kp

JARS:=jcommon-1.0.12.jar:jfreechart-1.0.9.jar:opencsv-1.8.jar

JFLAGS=-classpath $(CLASSPATH) -Xlint:deprecation -target 1.5

all: $(TARGETS) .classpath
zip: ECUxPlot-$(VERSION)r$(RELEASE).zip
scp: ECUxPlot-$(VERSION)r$(RELEASE).zip
	$(SCP) $< nyet.org:public_html/cars/files/

clean:
	rm ECUxPlot.exe ECUxPlot*.zip ECUxPlot.jar ECUxPlot-$(VERSION)r$(RELEASE).jar ECUxPlot.xml version.txt .classpath
	rm *.class
	find org/nyet -name \*.class | xargs rm

%.csv: %.kp mapdump
	./mapdump -r $(REFERENCE) $< > $@

.classpath: Makefile
	echo "export CLASSPATH=$(CLASSPATH)" > .classpath

version.txt: Makefile
	@rm -f version.txt
	echo $(VERSION)r$(RELEASE) > $@

mapdump.class: mapdump.java $(MP_CLASSES)
$(EX_CLASSES): $(UT_CLASSES) $(LF_CLASSES)
ECUxPlot-$(VERSION)r$(RELEASE).jar: $(EX_CLASSES)
	@rm -f $@
	jar cfe $@ org.nyet.ecuxplot.ECUxPlot `find org/nyet -name \*.class`

%.xml: %.xml.template
	sed -e 's/VERSION/$(VERSION)/g' < $< | sed -e 's/RELEASE/$(RELEASE)/g' > $@
ECUxPlot.exe: ECUxPlot-$(VERSION)r$(RELEASE).jar ECUxPlot.xml
	$(LAUNCH4J) '$(PWD)ECUxPlot.xml'

ECUxPlot-$(VERSION)r$(RELEASE).zip: ECUxPlot.exe ECUxPlot-$(VERSION)r$(RELEASE).jar ECUxPlot.sh version.txt
	@rm -f $@
	zip $@ $^ jcommon-1.0.12.jar jfreechart-1.0.9.jar opencsv-1.8.jar

%.class: %.java
	javac $(JFLAGS) $<
