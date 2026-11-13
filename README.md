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
config/experiment.conf
```

<<EXAMPLE OF THE .conf AND MEANING OF EACH KEY, PENDING>>

Golden Ball parameters:

| Parameter | Meaning |
|---|---|
| `numTeams` | Number of teams |
| `playersPerTeam` | Players per team |
| `maxSeasons` | Maximum number of seasons |
| `maxTrainingFailures` | Failed trainings before a player stops training |
| `customTrainingAfter` | Failures after which a custom training (Golden Help) is applied |
| `specialTransferAfter` | Seasons after which a special transfer happens |
| `stallSeasons` | Limit on seasons without improvement |


## Compilation

```bash
nim c -d:release src/main.nim
```

The executable is generated as `src/main`.

## Running

<<RUN WITH scripts/goldenball.sh AND PROCESSES, PENDING>>

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
