import filecmp
from matplotlib import pyplot as plt
import os
os.system("cls") # CLEAR PYTHON TERMINAL

# MODIFY VERILOG TXT FILE CONTENTS ######################
# I. READ TXT FILE
with open("verilog_test.txt") as f:
    contents = f.readlines()
    f.close

# II. MODIFY CONTENTS
# II.A. REMOVE DONE INDICES
idx = contents.index("DONE\n")
contents = contents[:idx]
for i in range(0, len(contents)):
    contents[i] = contents[i].replace(" ","").replace(",", ", ")
"""
for i in range(0, len(contents)):    
    print(contents[i], end="")
"""

# III. FIX LINE 1 INPUTS
print(contents[0])
xa = int(str((((contents[0].split(", "))[0].split("("))[1])[:-4]), 16)
ya = int(str((((contents[0].split(", "))[0].split("("))[1])[-4:]), 16)
xb = int(str((contents[0].split(", "))[1][:-4]), 16)
yb = int(str((contents[0].split(", "))[1][-4:]), 16)
xc = int(str((((contents[0].split(", "))[2])[:-2])[:-4]), 16)
yc = int(str((((contents[0].split(", "))[2])[:-2])[-4:]), 16)
print(f"Vertex 0 || x: [{xa}] y: [{ya}]\n", end="")
print(f"Vertex 1 || x: [{xb}] y: [{yb}]\n", end="")
print(f"Vertex 2 || x: [{xc}] y: [{yc}]\n", end="")
contents[0] = f"fillTriangle({xa}, {ya}, {xb}, {yb}, {xc}, {yc})\n"

# IV. DISPLAY RESULT
f = open("verilog_test_1.txt",'w')
f.close()
with open('verilog_test_1.txt', 'a') as f:
    for i in range(0, len(contents)):    
        f.write(contents[i])
f.close()

# V. COMPARE PYTHON AND VERILOG RESULTS
# VI. READ TXT FILEs
python_contents = "python_test.txt"
verilog_contents = "verilog_test_1.txt"
result = filecmp.cmp(python_contents, verilog_contents, shallow=False)
if (result):
    print("Python and verilog contents match")
elif (not result):
    print("Python and verilog contents don't match")

# PLOT VERILOG RESULTS ######################
# READ TXT FILE
with open("verilog_test_1.txt") as f:
    contents = f.readlines()
    f.close

# Coords value of 0 isn't compatible as the original verilog_test.txt
# can be 4-digits hex value if x-value is 0
x = [xa, xb, xc, xa]
y = [ya, yb, yc, ya]

points_x = []
points_y = []

# Create a figure and axis
fig, ax = plt.subplots()
# Plot lines
ax.plot(x, y, label='Line 1', linestyle='-', marker='o', color='blue')

# ITERATE POINTS
for i in range(1, len(contents)):    
    #print(contents[i], end="")
    points_x.append(int(contents[i].split(", ")[0][2:]))
    points_y.append(int(contents[i].split(", ")[1][2:]))

# Plot points
ax.scatter(points_x, points_y, label='Points', color='green', marker='^')

# Add grid, labels and legend, and invert y-axis
ax.grid(True)  # This will add a grid to the plot
ax.set_xlabel('X-axis')
ax.set_ylabel('Y-axis')
ax.set_xlim(0, 1280)  # Set x-axis limits from 0 to 6
ax.set_ylim(0, 720)  # Set y-axis limits from 0 to 12
ax.set_title('Lines and Points')
ax.legend()
ax.invert_yaxis()

# Show the plot
plt.show()