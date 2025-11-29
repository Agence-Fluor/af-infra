all: apply
	
./storage/tmp:
	mkdir -p ./storage/tmp

kube-install: ./storage/tmp/.kube-installed
./storage/tmp/.kube-installed: | ./storage/tmp
	./scripts/kube-install.sh
	touch ./storage/tmp/.kube-installed

tools-install: ./storage/tmp/.tools-installed
./storage/tmp/.tools-installed: | ./storage/tmp
	./scripts/tools-install.sh
	touch ./storage/tmp/.tools-installed

cluster-create: ./storage/tmp/.cluster_created
./storage/tmp/.cluster_created: ./storage/tmp/.kube-installed
	./scripts/cluster-create.sh
	touch ./storage/tmp/.cluster_created

PKL_TMP_DIR=./storage/tmp/cluster-yaml
apply: ./storage/tmp/.cluster_created $(wildcard cluster/*)
	rm -rf $(PKL_TMP_DIR)
	mkdir -p $(PKL_TMP_DIR)
	for pkl_file in $(shell find cluster -name '*.pkl'); do \
	  rel_path=$${pkl_file#cluster/}; \
	  out_path=$(PKL_TMP_DIR)/$${rel_path%.pkl}.yaml; \
	  pkl eval $$pkl_file -f yaml -o $$out_path; \
	done;
	kubectl apply -k $(PKL_TMP_DIR);
###


cluster-destroy:
	./scripts/cluster-destroy.sh
	rm -f ./storage/tmp/.cluster_created

kube-uninstall: delete-cluster
	./scripts/kube-uninstall.sh
	rm  -f ./storage/tmp/.kube-installed

tools-uninstall:
	./scripts/tools-uninstall.sh
	rm  -f ./storage/tmp/.tools-installed

.PHONY: temp kube-install kube-uninstall tools-install tools-uninstall cluster-create cluster-destroy
