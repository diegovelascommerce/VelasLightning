
.PHONY: venv
venv:
	python -m venv .venv

.PHONY: activate
activate:
	.\.venv\Scripts\Activate

.PHONY: requirements 
requirements:
	pip install -r requirements.txt

.PHONY: run 
run: 
	python wsgi.py
