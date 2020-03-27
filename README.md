# dvamp : "quay.io/kmayerb/dvamp:0.0.1"

<https://quay.io/repository/kmayerb/dvamp>

An AWS Batch ready docker container for using kmayerb/vampire (forked from matsengrp/vampire/vampire). Whereas the original matesngrp countainer is > 10GB and contains support for Olga as well as R, this is a more minimal container (still 5.83 GB) meant to recreate the python 3.6.10, tensorflow 1.14 environment needed to run a given branch of vampire. Once vampire is installed, one can train and evaluate a CDR3 VAE.

Currently the vampire conda env is pre-built in this container, but the vampire package is not installed. This step is saved for the the nextflow process. The example that follows, shows how to run the vampire demo.sh shell script.and publish the model training diagnostic metrics.

## Using the Container in Nextflow

Note in `m5.nf` the `params.vampire_branch` arguement controls which branch of the kmayerb/vampire repo gets pulled and installed. This is useful for specifying the desire chain (Beta, Gamma, or Delta) and allows use of a current run.sh.

### Example running vampire/vampire/demo.sh

```bash
nextflow run m5.nf -c local.config
```

local.config
```bash
process.executor = 'local'

docker {
    enabled = true
    temp = 'auto'
}

```

m5.nf workflow
```groovy

nextflow.preview.dsl=2

params.batchfile = "test_manifest.csv"
params.output_folder = "pub/"
params.vampire_branch = "master"

process foo {
    
    input:
      tuple name, file(x)
    output:
      tuple name, file("${x}.foo.txt")
    script:
      """
      head -n 2 ${x} > ${x}.foo.txt
      """
}

process bar {
    container "quay.io/kmayerb/dvamp:0.0.1"

    publishDir "${params.output_folder}"
    
    input:
      tuple name, file(x)
    
    output:
      tuple name, file("${x}.bar.txt"), file("m.txt"), file("diag.csv")
    
    script:
      """
      cut -d , -f 2 ${x} > ${x}.bar.txt 
      source ~/.bashrc
      conda activate vampire
      git clone -b ${params.vampire_branch} https://github.com/kmayerb/vampire.git
      pip install vampire/.
      python -c "import vampire; print(vampire.__version__);" > m.txt
      cd vampire/vampire/demo
      bash demo.sh
      cp _output_demo/diagnostics.csv ../../../diag.csv
      """
}

workflow {
    main:
      Channel.from(file(params.batchfile))
       .splitCsv(header: true, sep: ",")
       .map { sample ->
       [sample.name, file(sample.x1)]}
       .set{input_channel}
      foo(input_channel)
      foo.out.view()
      bar(foo.out)
      bar.out.view()
}

```


