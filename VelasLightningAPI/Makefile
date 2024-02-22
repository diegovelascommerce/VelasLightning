.PHONY: test
test:
ifdef t
ifdef m 
	pytest -s ./tests/$(t).py::$(m)
else
	@echo pytest -s ./tests/$(t).py
endif
else
	@echo pytest -s ./tests 
endif

.PHONY: decrypt
decrypt:
	gpg --decrypt voltage.creds.txt.asc

.PHONY: encrypt
encrypt:
	gpg --armor --encrypt --recipient ruahman voltage.creds.txt
