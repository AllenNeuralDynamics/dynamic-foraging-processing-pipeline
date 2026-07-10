# Dynamic Foraging Processing — Pipeline

End-to-end processing for [dynamic foraging](https://github.com/AllenNeuralDynamics/Aind.Behavior.DynamicForaging)
sessions: package a raw acquisition into NWB and run quality control. There are two capsules, both built on
the [`dynamic-foraging-processing`](https://github.com/AllenNeuralDynamics/dynamic-foraging-processing)
library.

The pipeline can be viewed here in Code Ocean: https://codeocean.allenneuraldynamics.org/capsule/8918069/tree

The raw data coming may have multiple modalities such as ephys or fiber, but this pipeline ONLY processes the behavior data. The other modalities are processed elsewhere in other modality-specific pipelines.

## Pipeline stages

| Stage | Capsule | Writes |
| --- | --- | --- |
| **NWB packaging** | [NWB capsule](https://codeocean.allenneuraldynamics.org/capsule/5492594/tree) | `behavior.nwb.zarr`, `processing.json` |
| **Quality control** | [QC capsule](https://codeocean.allenneuraldynamics.org/capsule/1897242/tree) | `quality_control.json`, `qc/` figures |

Flow: raw acquisition → **NWB capsule** → `behavior.nwb.zarr` → **QC capsule**
(raw acquisition + the NWB) → `quality_control.json`.

## Input
A raw acquisition directory in the
[`aind-behavior-dynamic-foraging`](https://github.com/AllenNeuralDynamics/Aind.Behavior.DynamicForaging)
data contract format (Harp registers, software events, task-logic / rig / session
schemas). The data will be stored under the **behavior** folder. In addition, at the top level, there will be the `aind-data-schema` metadata files. 

> **Note:** Data must be acquired in the data-contract and aind format to be compatible. See [here](https://docs.allenneuraldynamics.org/en/latest/policies_practices/data_organization.html) for more details on data organization.

## Outputs
- **NWB** (`behavior.nwb.zarr`) — acquisition container (4 derived event series + all
  raw contract streams) and the `trials` table.
- **Derived series** in the `acquisition` container of the NWB: `left_lick_time`, `left_reward_delivery_time`, `right_lick_time`, `right_reward_delivery_time`
- **`processing.json`** —
  [`aind-data-schema`](https://github.com/AllenNeuralDynamics/aind-data-schema)
  processing metadata.
- **`quality_control.json`** (+ `qc/` figures) — combined raw (contract QC) +
  processed (behavior) metrics.
- **`aind-data-schema`** files: `acquisition.json`, `instrument.json`, `data_description.json`, `procedures.json`, `processing.json`, `quality_control.json`
- The asset currently will have the <process_label> as `processed-behavior` as part of the output asset name. See [here](https://docs.allenneuraldynamics.org/en/latest/policies_practices/data_organization.html#derived-data-conventions) for more details on derived data.

## Usage
```python
from pathlib import Path

from hdmf_zarr.nwb import NWBZarrIO

from dynamic_foraging_processing.raw_data_loader import RawDataLoader
from dynamic_foraging_processing.pipeline import Pipeline

loader = RawDataLoader(path=Path("/data/<acquisition>"))
pipeline = Pipeline(loader)

# NWB capsule
pipeline.run_nwb("/results")

# QC capsule — the NWB is passed in
with NWBZarrIO("/results/behavior.nwb.zarr", mode="r") as io:
    pipeline.run_qc(io.read(), "/results")
```

## Reading the nwb
```python
from hdmf_zarr.nwb import NWBZarrIO

with NWBZarrIO("path_to_nwb/behavior.nwb.zarr", "r") as io:
    nwb = io.read()

left_lick_times = nwb.acquisition["left_lick_time"].timestamps[:]
trials_table = nwb.trials.to_dataframe()
```

## Logging formats
Logging is done using the standard [log schema](https://github.com/AllenNeuralDynamics/log-schema) library defined here. Sample output is shown below which tracks fields such as `acquisition_name`, `message`, `level`,  etc.
```
{"timestamp": "2026-07-10T00:52:59.748416Z", "level": "INFO", "message": "Begin processing...", "acquisition_name": "behavior_845023_2026-07-07_19-24-15", "process_name": "dynamic-foraging-nwb-packaging", "pipeline_name": "", "event_type": "stage_start"}
```

Logs can then be ingested into a dashboard either in tool such as Grafana or a web app to track the status of each capsule in the pipeline. In addition, for each derived output, a file called `output` will be present in Code Ocean which will contains the standard logging output. 

## Related
- **This library:** https://github.com/AllenNeuralDynamics/dynamic-foraging-processing
- **Data contract:** https://github.com/AllenNeuralDynamics/Aind.Behavior.DynamicForaging
- **NWB capsule:** https://github.com/AllenNeuralDynamics/dynamic_foraging_nwb_packaging_capsule
- **QC capsule:** https://github.com/AllenNeuralDynamics/dynamic_foraging_qc_capsule
