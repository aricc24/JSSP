import sys
import pandas as pd
import matplotlib.pyplot as plt

#python scripts/gantt.py schedule_0.csv gantt.png

src = sys.argv[1] if len(sys.argv) > 1 else "schedule.csv"
out = sys.argv[2] if len(sys.argv) > 2 else "gantt.png"

df = pd.read_csv(src)
fig, ax = plt.subplots(figsize=(18, 8))
for r in df.itertuples():
    ax.barh(r.machine, r.finish - r.start, left=r.start,
            color=plt.cm.tab20(r.job % 20),
            edgecolor="black", linewidth=0.3)
    if r.finish - r.start >= 3:
        ax.text((r.start + r.finish) / 2, r.machine, str(r.job + 1),
                ha="center", va="center", fontsize=5)

ax.set_yticks(sorted(df.machine.unique()))
ax.set_yticklabels([f"M{m + 1}" for m in sorted(df.machine.unique())])
ax.invert_yaxis()
ax.set_xlabel("time")
ax.set_ylabel("Machine")
ax.set_title(f"Makespan = {df.finish.max()}")
plt.tight_layout()
plt.savefig(out, dpi=150)