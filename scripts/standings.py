import sys
import pandas as pd
import matplotlib.pyplot as plt

#python scripts/standings.py standings_0.csv standings.png

src = sys.argv[1] if len(sys.argv) > 1 else "standings.csv"
out = sys.argv[2] if len(sys.argv) > 2 else "standings.png"

df = pd.read_csv(src)
df["captain_cost"] = df["captain_cost"].map(lambda v: f"{v:g}")

cols = ["pos", "team", "points", "wins", "draws", "losses", "captain_cost"]
headers = ["POS", "TEAM", "PTS", "G", "E", "P", "BEST"]

fig, ax = plt.subplots(figsize=(7, 0.5 * (len(df) + 1) + 0.6))
ax.axis("off")
table = ax.table(cellText=df[cols].values.tolist(), colLabels=headers,
                 cellLoc="center", loc="center",
                 colWidths=[0.1, 0.28, 0.12, 0.1, 0.1, 0.1, 0.2])
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1, 1.7)

for (row, col), cell in table.get_celld().items():
    cell.set_edgecolor("white")
    if row == 0:
        cell.set_facecolor("#3b1a8c")
        cell.set_text_props(color="white", weight="bold")
    else:
        cell.set_facecolor("#f2f2f2" if row % 2 else "white")
        if col == 2:
            cell.set_facecolor("#8fe3e8")
            cell.set_text_props(weight="bold")

ax.set_title("Golden Ball - final standings", pad=12)
plt.savefig(out, dpi=200, bbox_inches="tight")