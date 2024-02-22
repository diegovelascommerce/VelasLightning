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
