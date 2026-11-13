# JSSP — Golden Ball

Implementation of the Job Shop Scheduling Problem (JSSP) using the Golden Ball metaheuristic in Nim.

## Requirements

* Nim 2.x
* Nimble
* Python 3
* Matplotlib and pandas (only for the Gantt chart)

Project metadata is declared in `jssp_goldenball.nimble`.

## Installation

### 1. Install Nim

```bash
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
export PATH="$HOME/.nimble/bin:$PATH"
nim --version
nimble --version
```

### 2. Clone the repository

```bash
git clone <<REPOSITORY URL>>
cd jssp
```

### 3. Install Python plotting dependencies

```bash
python3 -m pip install matplotlib pandas
```

## Project Structure

```text
jssp/
├── instances/
│   ├── JSSP_40_40.txt
│   └── JSSP_100_100.txt
├── settings/
│   └── goldenball.conf
├── scripts/
│   ├── goldenball.sh
│   └── gantt.py
├── src/
│   ├── main.nim
│   ├── jssp/
│   │   ├── models/        
│   │   ├── io/           
│   │   ├── feasibility.nim
│   │   ├── cost.nim
│   │   ├── critical_path.nim
│   │   └── neighborhoods.nim
│   └── goldenball/
│       ├── types.nim
│       ├── moves.nim
│       ├── problem.nim
│       ├── training.nim
│       ├── league.nim
│       ├── transfers.nim
│       └── goldenball.nim
├── tests/
├── report/
├── jssp_goldenball.nimble
└── README.md
```

## Architecture

The project has two independent layers.

* `src/jssp/` models the problem: instance, disjunctive graph, feasibility check, cost (makespan), critical path and the N5 and N7 neighborhoods.
* `src/goldenball/` is the metaheuristic. It only knows a `Problem` (cost function, generator of feasible solutions and a list of coaches), so it does not depend on JSSP.

A solution is a chain of operations (a permutation with repetition of job indices, flattened into one array). Coaches propose moves (swap, insert, reverse, adjacent swap, N5, N7) that are applied and undone in place.

## Instance format

```text
n m 
machine duration machine duration ...   (one row per job)
```

Machines are indexed from 0. The bounds in the file are recomputed by the program: the upper bound is the sum of all durations and the lower bound is the maximum between the largest job sum and the largest machine sum.

## Configuration

Experiments are configured in:

```text
settings/goldenball.conf
```

Example:

```conf
INSTANCE=instances/JSSP_40_40.txt
BASE_SEED=135791113172064
TOTAL_RUNS=1
PROCESSES=1

NUM_TEAMS=4
PLAYERS_PER_TEAM=12
MAX_SEASONS=10000
MAX_TRAINING_FAILURES=100
CUSTOM_TRAINING_AFTER=3
SPECIAL_TRANSFER_AFTER=5
STALL_SEASONS=500
```

Experiment keys:

| Key | Meaning |
|---|---|
| `INSTANCE` | Path of the instance file |
| `BASE_SEED` | Base seed of the random number generator |
| `TOTAL_RUNS` | Number of independent runs |
| `PROCESSES` | Number of processes the runs are distributed among |

Golden Ball keys:

| Key | Meaning |
|---|---|
| `NUM_TEAMS` | Number of teams |
| `PLAYERS_PER_TEAM` | Players per team |
| `MAX_SEASONS` | Maximum number of seasons |
| `MAX_TRAINING_FAILURES` | Failed trainings before a player stops training |
| `CUSTOM_TRAINING_AFTER` | Failures after which a custom training (Golden Help) is applied |
| `SPECIAL_TRANSFER_AFTER` | Special transfer threshold (see the Golden Ball paper) |
| `STALL_SEASONS` | Stop if no season improves the search for this many seasons |

## Compilation

```bash
nim c -d:release src/main.nim
```

The executable is generated as `src/main`.

## Running

The recommended way to run an experiment is through the provided script.

First, make sure it has execution permissions:

```bash
chmod +x scripts/goldenball.sh
```

Then run it with the configuration file:

```bash
./scripts/goldenball.sh settings/goldenball.conf
```

The script reads the parameters from the given file and distributes `TOTAL_RUNS` among `PROCESSES` processes. Each process receives its own seed, derived from `BASE_SEED`, so the runs do not repeat. When all processes finish, the script prints the last lines of each log.

### Running directly

The executable can also be invoked directly:

```bash
./src/main \
    --instance:instances/JSSP_40_40.txt \
    --runs:1 \
    --seed:135791113172064 \
    --process:0 \
    --num-teams:4 \
    --players-per-team:12 \
    --max-seasons:10000 \
    --max-training-failures:100 \
    --custom-training-after:3 \
    --special-transfer-after:5 \
    --stall-seasons:500
```

Each process writes its log to `logs/process_*.log`.

## Gantt Chart

```bash
python3 scripts/gantt.py schedule_0.csv gantt.png
```

The CSV needs the columns `job`, `machine`, `start` and `finish`. The chart shows the job number inside each bar and the makespan in the title.

## Report


## Tests

```bash
nimble test
```

Individual tests:

```bash
nim c -r tests/test_cost.nim
```

## Author

**Ariadna García**
