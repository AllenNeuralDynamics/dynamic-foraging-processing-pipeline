# Dynamic Foraging Processing — Pipeline

End-to-end processing for [dynamic foraging](https://github.com/AllenNeuralDynamics/Aind.Behavior.DynamicForaging)
sessions: package a raw acquisition into NWB and run quality control. There are two capsules, both built on
the [`dynamic-foraging-processing`](https://github.com/AllenNeuralDynamics/dynamic-foraging-processing)
library.

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

> **Note:** Data must be acquired in the data-contract format to be compatible.

## Outputs
- **NWB** (`behavior.nwb.zarr`) — acquisition module (4 derived event series + all
  raw contract streams) and the `trials` table.
- **`processing.json`** —
  [`aind-data-schema`](https://github.com/AllenNeuralDynamics/aind-data-schema)
  processing metadata.
- **`quality_control.json`** (+ `qc/` figures) — combined raw (contract QC) +
  processed (behavior) metrics.
- **`aind-data-schema`** files: `acquisition.json`, `instrument.json`, `data_description.json`, `procedures.json`, `processing.json`, `quality_control.json`

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

## Related
- **This library:** https://github.com/AllenNeuralDynamics/dynamic-foraging-processing
- **Data contract:** https://github.com/AllenNeuralDynamics/Aind.Behavior.DynamicForaging
- **NWB capsule:** https://github.com/AllenNeuralDynamics/dynamic_foraging_nwb_packaging_capsule
- **QC capsule:** https://github.com/AllenNeuralDynamics/dynamic_foraging_qc_capsule
