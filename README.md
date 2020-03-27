# dvamp

An AWS Batch ready docker container for using kmayerb/vampire (forked from matsengrp/vampire/vampire). Whereas the original matesngrp countainer is > 10GB 
and contains support for Olga aswell as R, this is a minimal container meant to recreate the python 3.6.10, tensorflow 1.14 environment needed to install a given branch of vampire, needed to train and evaluate a CDR3 VAE.

Currently the vampire conda env is created, but the vampire package is not installed. It can be done so in a nextflow process, here showing how to run the demo.sh shell script, and publish the model training diagnostic metrics.


```groovy
params.output = "pub/"
params.vampire_branch = "master"

process{
	container "quay.io/kmayerb/dvamp:0.0.1"

	publishDir "${params.output_folder}"

	input:
		tuple name, file(x)
	
	output:
      tuple name, file("diagnostic.txt.txt")

	script:
		"""
		source ~/.bashrc
		conda activate vampire
		git clone -b ${params.vampire_branch} https://github.com/kmayerb/vampire.git
		pip install vampire/.
		python -c "import vampire; print(vampire.__version__);"
		cd vampire/vampire/demo
		bash demo.sh
		cp _output_demo/diagnostics.csv ../../../diagnostic.txt
		"""
}

```


