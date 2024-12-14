from matplotlib import pyplot as plt
import os
def fillTriangle(v0x, v0y, v1x, v1y, v2x, v2y):
    # Sample data for lines and points
    points_x = []
    points_y = []

    x = [v0x, v1x, v2x, v0x]
    y = [v0y, v1y, v2y, v0y]

    # Create a figure and axis
    fig, ax = plt.subplots()

    # Plot lines
    ax.plot(x, y, label='Line 1', linestyle='-', marker='o', color='blue')

    # ACTUAL FILLTRIANGLE COMMANDS
    x_min, y_min = min(v0x, v1x, v2x), min(v0y, v1y, v2y)
    x_max, y_max = max(v0x, v1x, v2x), max(v0y, v1y, v2y)

    """
    print(f"x_min:{x_min}, y_min:{y_min}")
    print(f"x_max:{x_max}, y_max:{y_max}")
    """

    delta_w0_row, delta_w0_col = v2x - v1x, v1y - v2y
    delta_w1_row, delta_w1_col = v0x - v2x, v2y - v0y
    delta_w2_row, delta_w2_col = v1x - v0x, v0y - v1y

    """
    print(f"delta_w0_row:{delta_w0_row}, delta_w0_col:{delta_w0_col}")
    print(f"delta_w1_row:{delta_w1_row}, delta_w1_col:{delta_w1_col}")
    print(f"delta_w2_row:{delta_w2_row}, delta_w2_col:{delta_w2_col}")
    """

    w0_row = edge_cross(v1x, v1y, v2x, v2y, x_min, y_min)
    w1_row = edge_cross(v2x, v2y, v0x, v0y, x_min, y_min)
    w2_row = edge_cross(v0x, v0y, v1x, v1y, x_min, y_min)

    """
    print(f"w0_row:{w0_row}")
    print(f"w1_row:{w1_row}")
    print(f"w2_row:{w2_row}\n")
    """

    with open('python_test.txt', 'w') as f:
        f.write(f"fillTriangle({v0x}, {v0y}, {v1x}, {v1y}, {v2x}, {v2y})\n")
        f.close()

    for y in range(y_min, y_max + 1):
        w0, w1, w2 = w0_row, w1_row, w2_row

        for x in range(x_min, x_max + 1):
            if w0 >= 0 and w1 >= 0 and w2 >= 0:
                # plotPoint(x, y)
                print(f"x:{x}, y:{y}")
                points_x.append(x)
                points_y.append(y)
                with open('python_test.txt', 'a') as f:
                    f.write(f"x:{x}, y:{y}\n")
                    f.close()
            w0 += delta_w0_col
            w1 += delta_w1_col
            w2 += delta_w2_col
            """
            print(f"x:{x}, y:{y} w0:{w0}")
            print(f"x:{x}, y:{y} w1:{w1}")
            print(f"x:{x}, y:{y} w2:{w2}\n")
            """
        w0_row += delta_w0_row
        w1_row += delta_w1_row
        w2_row += delta_w2_row
        """
        print(f"y:{y} w0_row:{w0_row}")
        print(f"y:{y} w1_row:{w1_row}")
        print(f"y:{y} w2_row:{w2_row}\n")
        """
    
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
    #plt.show()

def edge_cross(vax, vay, vbx, vby, px, py):
    abx, aby = vbx - vax, vby - vay
    apx, apy = px - vax, py - vay
    return abx*apy - apx*aby

os.system("cls")

# print(edge_cross(1,5,5,11,2,6))
# print(edge_cross(10,50,50,110,20,60))

# REQUIRED TESTS
print("\nfillTriangle(360,8,1008,472,128,328)"); fillTriangle(360,8,1008,472,128,328) # LARGE

# UP-ED TRIANGLE
#print("\nfillTriangle(1,100,500,600,100,500)"); fillTriangle(1,100,500,600,100,500)
#print("\nfillTriangle(100,100,500,500,100,500)"); fillTriangle(100,100,500,500,100,500)
#print("\nfillTriangle(300,100,500,500,100,500)"); fillTriangle(300,100,500,500,100,500)
#print("\nfillTriangle(500,100,500,500,100,500)"); fillTriangle(500,100,500,500,100,500)
#print("\nfillTriangle(600,100,500,500,100,600)"); fillTriangle(600,100,500,500,100,600)

# DOWN-ED TRIANGLE
#print("\nfillTriangle(100,100,500,0,0,500)"); fillTriangle(100,100,500,1,1,500)
#print("\nfillTriangle(100,100,500,100,100,500)"); fillTriangle(100,100,500,100,100,500)
#print("\nfillTriangle(100,100,500,100,300,500)"); fillTriangle(100,100,500,100,300,500)
#print("\nfillTriangle(100,100,500,100,500,500)"); fillTriangle(100,100,500,100,500,500)
#print("\nfillTriangle(100,0,500,100,600,500)"); fillTriangle(100,1,500,100,600,500)