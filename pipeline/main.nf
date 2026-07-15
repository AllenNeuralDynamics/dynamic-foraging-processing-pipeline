#!/usr/bin/env nextflow
// hash:sha256:b6e9ceff9935e9d5b37fd0346a54ea944d00e11805186341f148c5891bf4d615

// capsule - dynamic-foraging-behavior-only-nwb-packaging
process capsule_dynamic_foraging_behavior_only_nwb_packaging_2 {
	tag 'capsule-1435739'
	container "$REGISTRY_HOST/published/0f46e0d0-ad1d-4f0b-b97f-18d56327b18e:v1"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", mode: 'copy', saveAs: { filename -> filename.matches("capsule/results/.*\\.nwb\\.zarr") ? new File(filename).getName() : null }

	input:
	path 'capsule/data/dynamic_foraging_raw_data'

	output:
	path 'capsule/results/*.nwb.zarr', emit: to_capsule_dynamic_foraging_behavior_only_qc_1_1
	path 'capsule/results/*.nwb.zarr'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=0f46e0d0-ad1d-4f0b-b97f-18d56327b18e
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git -c credential.helper= clone --filter=tree:0 --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-1435739.git" capsule-repo
	else
		git -c credential.helper= clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-1435739.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

// capsule - dynamic-foraging-behavior-only-qc
process capsule_dynamic_foraging_behavior_only_qc_1 {
	tag 'capsule-4520453'
	container "$REGISTRY_HOST/published/6b0ab8c8-fefc-4009-8240-39bdedeabf15:v1"

	cpus 1
	memory '7.5 GB'

	publishDir "$RESULTS_PATH", mode: 'copy', saveAs: { filename -> new File(filename).getName() }

	input:
	path 'capsule/data/dynamic_foraging_nwb_base/'
	path 'capsule/data/dynamic_foraging_raw_data'

	output:
	path 'capsule/results/*'

	script:
	"""
	#!/usr/bin/env bash
	set -e

	export CO_CAPSULE_ID=6b0ab8c8-fefc-4009-8240-39bdedeabf15
	export CO_CPUS=1
	export CO_MEMORY=8053063680

	mkdir -p capsule
	mkdir -p capsule/data && ln -s \$PWD/capsule/data /data
	mkdir -p capsule/results && ln -s \$PWD/capsule/results /results
	mkdir -p capsule/scratch && ln -s \$PWD/capsule/scratch /scratch

	echo "[${task.tag}] cloning git repo..."
	if [[ "\$(printf '%s\n' "2.20.0" "\$(git version | awk '{print \$3}')" | sort -V | head -n1)" = "2.20.0" ]]; then
		git -c credential.helper= clone --filter=tree:0 --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-4520453.git" capsule-repo
	else
		git -c credential.helper= clone --branch v1.0 "https://\$GIT_ACCESS_TOKEN@\$GIT_HOST/capsule-4520453.git" capsule-repo
	fi
	mv capsule-repo/code capsule/code && ln -s \$PWD/capsule/code /code
	rm -rf capsule-repo

	echo "[${task.tag}] running capsule..."
	cd capsule/code
	chmod +x run
	./run

	echo "[${task.tag}] completed!"
	"""
}

params.dynamic_foraging_raw_data_url = 's3://aind-open-data/behavior_845023_2026-07-07_19-24-15'

workflow {
	// input data
	dynamic_foraging_raw_data_to_dynamic_foraging_behavior_only_qc_2 = Channel.fromPath(params.dynamic_foraging_raw_data_url + "/", type: 'any')
	dynamic_foraging_raw_data_to_dynamic_foraging_behavior_only_nwb_packaging_3 = Channel.fromPath(params.dynamic_foraging_raw_data_url + "/", type: 'any')

	// run processes
	capsule_dynamic_foraging_behavior_only_nwb_packaging_2(dynamic_foraging_raw_data_to_dynamic_foraging_behavior_only_nwb_packaging_3.collect())
	capsule_dynamic_foraging_behavior_only_qc_1(capsule_dynamic_foraging_behavior_only_nwb_packaging_2.out.to_capsule_dynamic_foraging_behavior_only_qc_1_1.collect(), dynamic_foraging_raw_data_to_dynamic_foraging_behavior_only_qc_2.collect())
}
