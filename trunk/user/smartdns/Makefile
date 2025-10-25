all: download extract compile

download:
	@echo "Downloading smartdns Release47..."
	wget -c https://github.com/pymumu/smartdns/archive/refs/tags/Release47.tar.gz -O smartdns_Release47.tar.gz
	@echo "Download completed"

extract:
	@echo "Extracting source..."
	tar -zxvf smartdns_Release47.tar.gz
	@echo "Extraction completed"

compile:
	@echo "Compiling smartdns..."
	cd smartdns-Release47/src && make
	@echo "Compilation completed"

clean:
	@echo "Cleaning up..."
	rm -rf smartdns-Release47
	rm -f smartdns_Release47.tar.gz
	@echo "Clean completed"

romfs:
	@echo "Installing to romfs..."
	$(ROMFSINST) -p +x ./smartdns.sh /usr/bin/smartdns.sh
	$(ROMFSINST) -p +x ./smartdns-Release47/src/smartdns /usr/bin/smartdns
	$(ROMFSINST) -d ./conf/ /etc_ro/
	@echo "Installation to romfs completed"
