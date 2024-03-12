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

.PHONY: lightning.proto 
lightning.proto:
	@echo "Downloading lightning.proto"
	cd ./LAPP/gRPC && curl -o lightning.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/lightning.proto

.PHONY: grpc 
grpc:
	@echo "Generating gRPC code from proto file"
	cd ./LAPP/gRPC && python -m grpc_tools.protoc --proto_path=googleapis:. --mypy_out=. --python_out=. --grpc_python_out=. lightning.proto

.PHONY: tls.cert 
tls.cert:
ifeq ($(PATH), velas)
	@echo "Downloading tls.cert from velas"
	scp ubuntu@45.33.22.210:/home/ubuntu/.lnd/tls.cert tls.velas.cert
else
	@echo "Please set PATH=xxxxx"
endif

.PHONY: admin.macaroon
admin.macaroon:
ifeq ($(PATH), velas)
	@echo "Downloading admin.macaroon from velas"
	scp ubuntu@45.33.22.210:/home/ubuntu/.lnd/data/chain/bitcoin/testnet/admin.macaroon admin.velas.macaroon
else
	@echo "Please set PATH=xxxxx"
endif

.PHONY: docker 
docker: 
	cd docker && DOCKER_DEFAULT_PLATFORM=linux/arm64 docker compose up -d 



