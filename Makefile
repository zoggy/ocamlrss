.PHONY: all clean
all:
	jbuilder build @install rsstest.exe
clean:
	rm -rf _build
